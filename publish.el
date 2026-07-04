;;; publish.el --- Build ./greg.out with org-publish -*- lexical-binding: t; -*-

;; This is the whole build system for the blog.  There is no Hugo, no CI:
;; you run this file and it turns the .org files in content/ into HTML in
;; public/.
;;
;; Usage:
;;   Batch (from a shell):   emacs --batch --load publish.el
;;   Interactively in Emacs: M-x load-file RET publish.el RET
;;                           then M-x org-publish-all
;;
;; See notes/how-this-site-works.org for the full explanation.

;;; --- load path / requires -------------------------------------------------

(require 'ox-publish)
(require 'ox-html)
(require 'org)

;;; --- bootstrap htmlize (for source-code highlighting) ---------------------
;; We keep a private package dir inside the repo (.build/elpa, gitignored) so
;; the build does not depend on your interactive Emacs configuration and works
;; the same in batch mode.  htmlize is only needed to colourise code blocks;
;; if it can't be installed (e.g. offline) the site still builds, just with
;; plainer code blocks.

(require 'package)
(setq package-user-dir
      (expand-file-name ".build/elpa"
                        (file-name-directory (or load-file-name buffer-file-name))))
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)
(unless (package-installed-p 'htmlize)
  (ignore-errors (package-refresh-contents))
  (ignore-errors (package-install 'htmlize)))
(require 'htmlize nil t)

;;; --- site constants -------------------------------------------------------

(defvar greg/site-dir
  (file-name-directory (or load-file-name buffer-file-name))
  "Absolute path to the repo root (where this file lives).")

;; The site is a GitHub *project* page served under /me/, so every absolute
;; link needs this prefix.  Change both if you ever move to a root domain.
(defvar greg/url-prefix "/me"
  "Absolute URL path prefix for the site (no trailing slash).")
(defvar greg/base-url "https://gsilvers.github.io/me"
  "Full canonical base URL (no trailing slash). Used for the RSS feed.")

(defvar greg/site-title "./greg.out")
(defvar greg/site-subtitle "Greg Silverstein's Home on the internet")
(defvar greg/author "Greg Silverstein")

;; Intro prose shown at the top of the home page. Edit here to change it.
(defvar greg/home-intro
  "Welcome to my home on the internet. I'm Greg — software engineer, \
fisherman, dog dad, Emacs user. Below is everything I've written, newest first.")

;;; --- HTML export settings -------------------------------------------------

(setq org-publish-use-timestamps-flag nil ; always full rebuild (site is tiny)
      org-export-with-toc nil
      org-export-with-section-numbers nil
      org-export-with-title nil            ; we render the title ourselves (preamble)
      org-export-time-stamp-file nil
      org-html-doctype "html5"
      org-html-html5-fancy t
      org-html-htmlize-output-type 'css    ; code -> CSS classes (themed in style.css)
      org-html-validation-link nil
      org-html-head-include-scripts nil
      org-html-head-include-default-style nil
      org-html-container-element "section")

;; Shared <head>: our stylesheet, RSS autodiscovery, viewport.
(setq org-html-head
      (concat
       (format "<link rel=\"stylesheet\" href=\"%s/css/style.css\">\n" greg/url-prefix)
       (format "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"%s\" href=\"%s/index.xml\">\n"
               greg/site-title greg/url-prefix)
       "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"))

(defun greg/preamble (info)
  "Site header + per-page title/date block. Rendered above #content on every page."
  (let* ((title (org-export-data (plist-get info :title) info))
         (date  (org-export-get-date info "%Y-%m-%d")))
    (concat
     "<header class=\"site-header\"><div class=\"wrap\">"
     (format "<div class=\"brand\"><a class=\"logo\" href=\"%s/\">%s</a>"
             greg/url-prefix greg/site-title)
     (format "<div class=\"subtitle\">%s</div></div>" greg/site-subtitle)
     "<nav>"
     (format "<a href=\"%s/\">Home</a>" greg/url-prefix)
     (format "<a href=\"%s/about.html\">About</a>" greg/url-prefix)
     (format "<a href=\"%s/resume.html\">Resume</a>" greg/url-prefix)
     (format "<a href=\"%s/index.xml\">RSS</a>" greg/url-prefix)
     "<a href=\"https://github.com/gsilvers\">GitHub</a>"
     "</nav></div></header>"
     ;; per-page heading (skipped when title is empty, e.g. the home page)
     (if (and title (> (length (string-trim title)) 0))
         (concat "<div class=\"wrap page-head\">"
                 (format "<h1 class=\"page-title\">%s</h1>" title)
                 (if (and date (> (length date) 0))
                     (format "<div class=\"page-meta\">%s</div>" date)
                   "")
                 "</div>")
       ""))))

(defun greg/postamble (_info)
  "Site footer."
  (concat
   "<footer class=\"site-footer\"><div class=\"wrap\">"
   (format "Written by %s &middot; " greg/author)
   "theme <a href=\"https://github.com/protesilaos/ef-themes\">ef-cherie</a> &middot; "
   "built with org-publish in GNU Emacs"
   "</div></footer>"))

(setq org-html-preamble  #'greg/preamble
      org-html-postamble #'greg/postamble)

;; Posts reference images/links with root-absolute paths (e.g. /me/2023.../x.webp).
;; Org's HTML exporter treats a leading "/" as an absolute *filesystem* path and
;; emits src="file:///me/...", which is broken on the web. Strip that prefix so
;; the links stay proper root-relative URLs.
(defun greg/fix-abs-file-links (output backend _info)
  (if (org-export-derived-backend-p backend 'html)
      (replace-regexp-in-string "file://\\(/me/\\)" "\\1" output)
    output))
(add-to-list 'org-export-filter-final-output-functions #'greg/fix-abs-file-links)

;;; --- reading post metadata ------------------------------------------------

(defun greg/posts-directory ()
  (expand-file-name "content/posts/" greg/site-dir))

(defun greg/post-files ()
  "All published post .org files, newest first."
  (let ((files (directory-files (greg/posts-directory) t "\\.org\\'")))
    (sort (seq-remove #'greg/draft-p files)
          (lambda (a b) (string> (greg/post-date a) (greg/post-date b))))))

(defun greg/keyword (file kw)
  "Return the value of #+KW: from FILE, or nil."
  (with-temp-buffer
    (insert-file-contents file)
    (let ((case-fold-search t))
      (when (re-search-forward (format "^#\\+%s:[ \t]*\\(.*\\)$" kw) nil t)
        (string-trim (match-string 1))))))

(defun greg/post-title (file) (or (greg/keyword file "TITLE") (file-name-base file)))

(defun greg/post-date (file)
  "ISO date string (YYYY-MM-DD) for FILE, from #+DATE, else empty."
  (let ((d (greg/keyword file "DATE")))
    (if (and d (string-match "\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)" d))
        (match-string 1 d)
      "")))

(defun greg/draft-p (file)
  (let ((d (greg/keyword file "DRAFT"))) (and d (string-equal (downcase d) "true"))))

(defun greg/post-url (file)
  (format "%s/posts/%s.html" greg/url-prefix (file-name-base file)))

(defun greg/post-description (file)
  "A short summary for RSS: #+DESCRIPTION if present, else the first paragraph."
  (or (greg/keyword file "DESCRIPTION")
      (with-temp-buffer
        (insert-file-contents file)
        (goto-char (point-min))
        ;; skip keyword lines and blank lines and headings
        (while (and (not (eobp))
                    (looking-at "^\\(#\\+\\|[ \t]*$\\|\\*+ \\)"))
          (forward-line 1))
        (let ((start (point)))
          (forward-paragraph)
          (string-trim (buffer-substring-no-properties start (point)))))))

;;; --- home page (generated) ------------------------------------------------

(defun greg/build-index (&rest _)
  "Regenerate content/index.org: intro prose + a date-sorted list of posts."
  (let ((out (expand-file-name "content/index.org" greg/site-dir)))
    (with-temp-file out
      (insert "# -*- buffer-read-only: t -*-\n")
      (insert "# AUTO-GENERATED by publish.el (greg/build-index). Do not edit by hand.\n")
      (insert "#+TITLE:\n\n")
      (insert greg/home-intro "\n\n")
      (insert "#+BEGIN_EXPORT html\n")
      (insert "<ul class=\"post-list\">\n")
      (dolist (f (greg/post-files))
        (insert (format "  <li><span class=\"date\">%s</span><a href=\"%s\">%s</a></li>\n"
                        (greg/post-date f) (greg/post-url f)
                        (greg/xml-escape (greg/post-title f)))))
      (insert "</ul>\n")
      (insert "#+END_EXPORT\n"))))

;;; --- RSS feed (generated, no ox-rss dependency) ---------------------------

(defun greg/xml-escape (s)
  (setq s (or s ""))
  (dolist (pair '(("&" . "&amp;") ("<" . "&lt;") (">" . "&gt;")) s)
    (setq s (replace-regexp-in-string (regexp-quote (car pair)) (cdr pair) s t t))))

(defun greg/rss-date (iso)
  "Convert YYYY-MM-DD to an RFC-822 date for RSS."
  (if (and iso (string-match "\\`[0-9]" iso))
      (format-time-string "%a, %d %b %Y 00:00:00 +0000"
                          (encode-time (parse-time-string (concat iso " 00:00:00"))) t)
    (format-time-string "%a, %d %b %Y %H:%M:%S +0000" nil t)))

(defun greg/build-rss (&rest _)
  "Write public/index.xml, an RSS 2.0 feed of all posts."
  (let ((out (expand-file-name "public/index.xml" greg/site-dir)))
    (make-directory (file-name-directory out) t)
    (with-temp-file out
      (insert "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
      (insert "<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">\n<channel>\n")
      (insert (format "<title>%s</title>\n" (greg/xml-escape greg/site-title)))
      (insert (format "<link>%s/</link>\n" greg/base-url))
      (insert (format "<description>%s</description>\n" (greg/xml-escape greg/site-subtitle)))
      (insert (format "<atom:link href=\"%s/index.xml\" rel=\"self\" type=\"application/rss+xml\"/>\n"
                      greg/base-url))
      (dolist (f (greg/post-files))
        (let ((url (concat "https://gsilvers.github.io" (greg/post-url f))))
          (insert "<item>\n")
          (insert (format "  <title>%s</title>\n" (greg/xml-escape (greg/post-title f))))
          (insert (format "  <link>%s</link>\n" url))
          (insert (format "  <guid>%s</guid>\n" url))
          (insert (format "  <pubDate>%s</pubDate>\n" (greg/rss-date (greg/post-date f))))
          (insert (format "  <description>%s</description>\n"
                          (greg/xml-escape (greg/post-description f))))
          (insert "</item>\n")))
      (insert "</channel>\n</rss>\n"))))

;;; --- publish project definition -------------------------------------------

(setq org-publish-project-alist
      (list
       ;; Individual blog posts -> public/posts/*.html
       (list "greg-posts"
             :base-directory (expand-file-name "content/posts" greg/site-dir)
             :base-extension "org"
             :recursive nil
             :publishing-directory (expand-file-name "public/posts" greg/site-dir)
             :publishing-function 'org-html-publish-to-html
             :completion-function 'greg/build-rss)

       ;; Top-level pages (home/about/resume) -> public/*.html
       ;; index.org is regenerated first by greg/build-index.
       (list "greg-pages"
             :base-directory (expand-file-name "content" greg/site-dir)
             :base-extension "org"
             :recursive nil
             :publishing-directory (expand-file-name "public" greg/site-dir)
             :publishing-function 'org-html-publish-to-html
             :preparation-function 'greg/build-index)

       ;; Static assets (css + images) copied verbatim -> public/...
       (list "greg-static"
             :base-directory (expand-file-name "static" greg/site-dir)
             :base-extension "css\\|js\\|png\\|jpe?g\\|gif\\|webp\\|svg\\|ico\\|woff2?\\|ttf\\|pdf\\|txt"
             :recursive t
             :publishing-directory (expand-file-name "public" greg/site-dir)
             :publishing-function 'org-publish-attachment)

       (list "greg" :components '("greg-posts" "greg-pages" "greg-static"))))

;; When run in batch (emacs --batch --load publish.el), build everything.
(when noninteractive
  (greg/build-index)
  (org-publish "greg" t)
  (message "\nSite built into %spublic/" greg/site-dir))

(provide 'publish)
;;; publish.el ends here
