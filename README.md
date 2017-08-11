# shadow_crypt
This is a custom Inspec resource that simplifies password audits. The resource is passed a list of passwords and determines if any users on the system match these passwords after hashing (compared in /etc/shadow). The control should be skipped or the passed parameters should be modified statically or using .yml attributes in the inspec file. 
