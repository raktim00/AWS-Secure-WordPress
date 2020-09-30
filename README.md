# The Full procedure of doing this practical you can find in below link :

## “WebApp on AWS EC2 Instance with Best Possible Security !!!” by Raktim Midya - https://link.medium.com/bDclyTgfbab

## Problem Statement :
### We have to create a web portal for our company with all the security as much as possible.

### So, we use WordPress software with a dedicated database server. The database should not be accessible from the outside world for security purposes. We only need to public the WordPress to clients.

#### So here are the steps for proper understanding!

- 1. Write an Infrastructure as code using Terraform, which automatically creates a VPC.
- 2. In that VPC we have to create 2 subnets:
- 3. a) public subnet - Accessible for Public World! 
- 4. b) private subnet - Restricted for Public World! 
- 5. Create a public-facing internet gateway to connect our VPC/Network to the internet world and attach this gateway to our VPC.
- 6. Create a routing table for Internet gateway so that instance can connect to the outside world, update and associate it with the public subnet.
- 7. Launch an ec2 instance that has WordPress setup already having the security group allowing port 80 so that our client can connect to our WordPress site.
- 8. Also attach the key to the instance for further login into it.
- 9. Launch an ec2 instance that has MySQL setup already with security group allowing port 3306 in private subnet so that our WordPress VM can connect with the same.
- 10. Also attach the key with the same.

##### Note: WordPress instance has to be part of the public subnet so that our client can connect our site.
##### MySQL instance has to be part of a private subnet so that the outside world can’t connect to it.
##### Don’t forget to add auto IP assign and auto DNS name assignment option to be enabled.
