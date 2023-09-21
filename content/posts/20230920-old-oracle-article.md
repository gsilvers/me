---
title: "20230920 Old Oracle Article"
date: 2023-09-20T20:48:28-04:00
draft: true
---

# About this post

This post is an older blog article I created when I tried out Medium a few years ago. The [article](https://gregpoked.medium.com/connecting-dbeaver-to-oracle-free-cloud-tier-database-with-keyfiles-ed835f990031) is still on the internet but I detest the fact that Medium articles are not plain text, and not portable. This is just an attempt on my part to convert said article to markdown and get it back under my control.

The original post is from September 2020. I'm pretty sure this still works but I don't interface with anything Oracle at my current job. If you have corrections

 I'd love to [speak about it with anyone](https://hachyderm.io/@pokeypoke) about updates please reach out and I will post your updates with credits.

# Original Article 

## Connecting DBeaver to Oracle Free Cloud Tier Database (With Keyfiles)

It would be both wonderful but also terrible if everything were easy no? Someone would just have instructions for you to get chugging on. This is not the case especially with software. Documentation is not always present or easy to find. This is pretty true if you want to connect to oracle’s free cloud tier databases using DBeaver. There are plenty of guides on how to jump on an oracle server on your network but very little about the cloud instances. The first result (at least as of writing) on google to connecting DBeaver to Oracle Cloud is a GitHub issue for DBeaver This is not very re-assuring and neither are any of the top 5 results. Further down the details do exist in oracle’s guidance but they are pretty generic and do not explain where a specific IDE like DBeaver stores this stuff. Don’t worry I wrote down what I did! Assuming you landed on this page I won’t bore you with the details of how to sign up for Oracle always free cloud. I’m going to assume like me you’re using oracle’s free cloud to do some learning or just to mess around and that you’re trying to use DBeaver rather than the web based copy of SQL developer.

This guide will cover two main steps. First how to generate the files needed from your oracle free tier relational database. Second how to configure DBeaver to use these files. This was done using Oracle 19c on their free cloud tier and DBeaver 7.1.5.202008180601. I’m going to assume if you’re here you’ve already got DBeaver installed and have a free (or paid) oracle cloud Autonomous Database.
The first step to being able to log in is to retrieve the required documents from your oracle instance. Oracle cloud databases want you to use a key-file that they provide in a downloadable wallet. First you want to navigate to your database and simply click into it:

![Image of Oracle Cloud Dashboard with Database Showing](/me/20230920/image_1.webp)

Once connected click the DB connection button. Hit the rotate wallet button which may prompt you to set a password if you have not yet. Do so and then hit the download button which will download a zipped folder to your machine. Extracted you should see a directory with contents like so:


![Image showing unzipped file contents including oracle wallet files](/me/20230920/image_2.webp)

These files contain a nicely generated tnsnames.ora file as well as several key files to allow you secure connections to the database. Save these on your computer. They are likely to be re-used so its a good idea to generate something like ~/.config/oracle/ and place these files there. The next step on this is get DBeaver reading in these files and connecting. First and foremost if you have not yet download the JBDC driver for Oracle Databases so DBeaver can speak to your DB. Download Drivers from here. You also need to install the oracle drivers. A good guide to this is here.

Once you have the drivers installed within DBeaver create a new database connection. Click the plug with a plus and select oracle:

![Image showing DBeaver connection drop down menu with Oracle logo highlighter](/me/20230920/image_3.webp)

Since you have a nice fancy TNS file to save your fingers typing on the next screen select the TNS tab for connection type. Again a TNS file is nothing fancy its just a markup file with the connection details in it.

![Image showing connection pop up with TNS selected](/me/20230920/image_4.webp)

On the TNS page browse to your TNS file and select one of the provided connections. In general I use the high. I’ve not read the oracle documentation as to why there are several connection strings for a simple database but _high certainly works. For the database connections you can use a user you have created or admin. Whatever you decide chose database native and enter your credentials. It should look something like this:

![Image showing the same connection pop up with password and user populated](/me/20230920/image_5.webp)

You would think hey, username and password I am done. Nope. You need to also import Oracle’s key files as basically a second factor to authenticate. Navigate to the driver properties tab and you should see a gross list of parameters shown as a table:

![Image showing the driver properties tab of this window](/me/20230920/image_6.webp)

Scroll down about 1 page and you will see the parameters you need to set which are javax.net.ssl.keyStore, avax.net.ssl.keyStorePassword, javax.net.ssl.trustStore and finally java.net.ssl.trustStorePassword. These are pretty easy. For the ssl keystore locate the wallet zip file you extracted earlier. Paste in here the path to this and specifically address keystore.jks so likely you will be entering something like ~/.config/oracle/wallet12345/keystore.jks. The ssl the same is true for the trust store which is simply the same directory but the file truststore.jks. The passwords will be whatever password you used when creating the oracle password wallet. When done you should have something like this:

![Same image showing the keystore value changed](/me/20230920/image_7.webp)

After this you can tweak some other settings if you want a longer or shorter timeout or anything like that. But this should be it. Once you get the trust files where you need them the connection will work. You can pop open a script or worksheet and test to verify:

![Screenshot of DBeaver SQL sheet with a sample query completed IE select 1 from dual;](/me/20230920/image_8.webp)

Nothing groundbreaking here but I did not find any clear documentation when I did this so I figured may as well get typing. Hopefully this helps someone out.

Bye Bye
