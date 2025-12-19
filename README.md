# Inception

The basics of Inception


1. What is a website?

When a user or like a personal visits reddit.com or like youtube.com, he or she is not
directly connecting to their computer. The browser sends a request, and the web server
sends back like a HTML/CSS/JavaScript that ,the browser would display.Thatwebserveris a 
program running on their machine waiting for requests.


2. NGINX - The webserver NGINX is that program. It's like a receptionist at the hotel.

	• Listens for incoming requests(on ports 443 for HTTPS)
	• Decides what has ot be done with them.
	• Sends back responces to the brower for the user(Web pages,images,etc).
	• Handles SSL/TLS (the encryption that makes HTTPS secure).


3. WordPress - The Website Aplication WordPress is a Software that helps create and 
   manage websites without writing HTML from scratch. Think of it like:

	• NGINX is the building and front desk.
	• WordPress is the actual business operating inside.
	• It stores articles, image, user accounts in a database.
	 • It generates HTML pages dynamically based on what's stored.

4. PHP- The Programming Language WordPress is writen in php. When someone requests a page:

	• NGINX recives a request.
	• Passes it to PHP-FPM(Fasr CGI Process Manager-a program that runs PHP code).
	• PHP executes WordPress code.
	• Generates HTML.
	• Sends it back through NGINX to the user.

5. MariaDB - The Database This is where WordPress stores everything:

	• Your blog posts.
	• User Acccounts.
	• Comments.
	• Settings.



What is a Docker, Fundimentally?

Dockers lets you package an application with everything it needs(code, libraries, dependencies) into a container that runs the same way everywhere.

You can think of it like: You're shipping furniture.

	• Without Docker: You ship loose parts, hope the customer has the right
	  tools, right manual, right screws. So this might just not work.
	• With Docker: You would ship the complete,assembles unit. Like RTF or
	  RTR. Open the box, and it works.


Core Docker Concepts:

1. Docker Image

	• A Blueprint/template.
	• Read-only.
	• Contains: OS files, your application, dependencies, configuration.
	• Like a recipe for cake.

2. Docker Container

	• A runing instance of an image.
	• Isolated process(es) on the system.
	• Can read/write data while running.
	• Like the actual baked cake.

3. Dockerfile

	• Instructions to build an image.
	• Text file that says"Start with Alpine Linux, install NGINX, copy
	  config files, run NGINX"



Steps:

Install VM .
Install docker inside the VM.


Ubuntu gnom


docker 101.
docker desktop.