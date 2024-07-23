Update the Package List:

The script starts by updating the list of available packages. This ensures you have the latest information about available software versions.
Command: apt-get update
Install Nginx:

It installs Nginx if it's not already installed on the container. Nginx is the web server software we are configuring.
Command: apt-get install -y nginx
Create the nginx User:

This step checks if the nginx user exists. If not, it creates a new user named nginx. This user will run the Nginx server instead of the root user.
Command: useradd -r -s /sbin/nologin nginx
-r flag creates a system account.
-s /sbin/nologin sets the shell to nologin, meaning this user cannot log in to the system.
Modify Nginx Configuration:

The script modifies the Nginx configuration file to make Nginx run as the nginx user and listen on port 8080.
Commands:
sed -i 's/^user .*/user nginx;/' /etc/nginx/nginx.conf: This changes the user directive in the Nginx configuration file to nginx.
sed -i 's/listen 80;/listen 8080;/' /etc/nginx/sites-available/default: This changes the listen directive in the default site configuration to port 8080.
Adjust Permissions:

The script changes the ownership of the necessary directories to the nginx user. This ensures that the nginx user has the required permissions to read/write logs and serve web content.
Commands:
chown -R nginx:nginx /var/log/nginx
chown -R nginx:nginx /var/lib/nginx
chown -R nginx:nginx /var/www/html
Restart Nginx:

Finally, the script restarts the Nginx service to apply the changes made to the configuration.
Command: systemctl restart nginx
Simple Explanation
Don't use the root user: Running the web server as the root user is risky because if a hacker breaks in, they can do anything on your system. Instead, we run the server as a less powerful user, called nginx.

Listen on port 8080: Normally, web servers use port 80, but we are changing it to use port 8080.

Steps the script takes:

It installs Nginx if it's not already there.
It creates a new user named nginx to run the server.
It changes the Nginx settings so it runs as this nginx user and listens on port 8080.
It makes sure the nginx user has the right permissions to access necessary files.
It restarts Nginx to apply these changes.
By doing this, we make our server more secure and ensure it works on the correct port
