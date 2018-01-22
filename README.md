*** powervc_csv ***

Section 1:
** Version **
		1.0.3

Section 2:
** Description **

		powervc_csv is a ruby based tool to build VMs/LPARs in PowerVC using CSV formatted files as input for VM specifications.
		The tool also gathers existing PowerVC managed resources and reports them as output to csv files, or to the terminal screen.

Section 3:
** Setup / Requirements **

		1) Run the setup.sh script file. (if you are using the Docker container image, skip this step, please see Docker Container Image section below)
		   The script installs and configures rvm to manage ruby and other dependent packages.
		   The script also install the below mentioned ruby gems:
		   rest-client, json, terminal-table

		2) The powervcrc file is used for providing the PowerVC server URL, and user credentials.
		   Fill the file with the required details.
		   Please refer to Section in this guide for the required information to fill in the powervcrc file.

		3) A sample input.csv is included.
		   This format should be used to build LPARs / VMs in PowerVC.
		   Please refer to Section in this guide for the required information to fill in the input file.

		4) The following packages are the pre-requisities for using the tool. (if you are using the Docker container image, skip this step, please see Docker Container Image section below)
			If you choose not to use the setup.sh provided with this tool, you would need to get the below mentioned packages installed:
		   * Ruby v2.2.0 or higher
		   * ruby-devel(rpm) or ruby-dev(apt-get)
		   * gcc, g++ (C, C++ compilers), make
		  Followed by the ruby gems
		   * rest-client, json, terminal-table

		5) The following ruby gems are required for using the tool.
		   * rest-client
		   * json
		   * terminal-table

		6) Setting up the SSL certificate file for authentication with PowerVC node.

			(a) Copy the SSL certificate file from PowerVC server to your local desktop.

    			# scp root@<powervc-ip>:/etc/pki/tls/certs/powervc.crt /home/powervc

		  (b) Convert the .crt file to .pem using the openssl command in your local desktop.
    			# openssl x509 -in /home/powervc/powervc.crt -out /home/powervc/powervc.pem -outform PEM

			(c) Once you have generated the .pem file, you need to tell the powervc_csv tool to use the new .pem file for SSL authentication. In the powervcrc file, there is a new line 				added to provide the full path to the .pem file.

				## ssl_ca_file = <path_to_ssl_file>
   			 	ssl_ca_file = /home/powervc/powervc.pem

Section 4:
** Docker Container Image **

		If you are using the "powervc_csv" Docker container image to use the tool, the tool is placed under the /powervc_csv directory in the container image.
		All of the requirements mentioned in the Setup section are included in the Docker Container image, so users dont have to go through the Setup steps.

Section 5:
** Usage **

	ruby powervc_csv.rb <action> <resource>

	The tool takes two arguments - action, resource

	<action>
		Specifies the action to be performed.
		Only one of the below list of actions can be specified.
		action is a mandatory argument.

		q | query:  			Queries the specified resource type and displays the output on the screen

		r | report: 			Creates a new csv file and reports the specified resource details
							  			The output file will be created in the same source directory
							  	  	The output file name is in the format - <resource>_<date&time>.csv

		b | build:  			Builds the LPARs / VMs in PowerVC
							  			Build operation expects a CSV formatted file as its resource argument

	  d | delete: 			Deletes the LPARs / VMs in PowerVC
							  			Delete operation expects one or more LPAR names to be deleted for the resource argument
							  	  	If more than one LPAR needs to be deleted, the names must be provided as a comma-separated list

		as | add-storage	Adds multiple Storage volumes to existing Virtual Machines in PowerVC
											The volume specifications are provided using a CSV formatted input file

	<resource>
		Specifies the selection of resource to perform action on.
		The available options for the resource argument are based on the selected action argument.
		At least one of the below resources must be provided for query and report actions.

			1) The build action accepts a CSV-formatted file as its resource.

			2) The delete action accepts a comma-separated list of LPARs / VMs to be deleted.

			3) The query action accepts the below options for resource.
				- vms | servers: 				Managed Virtual Machines / LPARs
				- flavors | compute_templates: 	All Compute Templates
				- networks: 					All Networks
				- volumes: 						Managed Storage volumes
				- storage_templates: 			All Storate Templates
				- images: 						All Images
				- storage_providers: 			Managed Storage Providers
				- scg: 							All Storage Connectivity Groups
				- projects: 					All Projects
				- fabrics: 						Managed Fabrics
				- host_groups: 					All Host Groups, along with Host details
				- all: 							All resources in the above list

			4) The report action accepts the below options for resource.
				- vms | servers: 				Managed Virtual Machines / LPARs
				- flavors | compute_templates: 	All Compute Templates
				- networks: 					All Networks
				- volumes: 						Managed Storage volumes
				- storage_templates: 			All Storate Templates
				- storage_providers: 			Managed Storage Providers
				- scg: 							All Storage Connectivity Groups
				- all: 							All resources in the above list

Section 6:
** Examples **

		1) ruby powervc_csv.rb build appA_lpars.csv

			Builds the LPARs / VMs as per their specs provided in the appA_lpars.csv file.

		2) ruby powervc_csv.rb query vms

			Queries the information on existing Virtual Machines in the PowerVC and reports them on the terminal screen.

		3) ruby powervc_csv.rb query storage_templates

			Queries for information on existing Storage Templates in the PowerVC node and reports them on the terminal screen.

		4) ruby powervc_csv.rb query all

			Queries for information on all resources in the PowerVC node and reports them on the terminal screen.

		5) ruby powervc_csv.rb report networks

			Queries for information on existing networks in the PowerVC node and reports them to a csv file.

		6) ruby powervc_csv.rb report images

			Queries information on existing images in the PowerVC node and reports them to a csv file.

		7) ruby powervc_csv.rb report all

			Queries information on all resources in the PowerVC node and report them to a csv file.

		8) ruby powervc_csv.rb delete lpar1,lpar2,lpar3

			Deletes the three lpars mentioned in the comma-separated list - lpar1, lpar2, lpar3

		9) ruby powervc_csv.rb add-storage volumes_for_lpars.csv

	Please refer to EXAMPLES.txt for more examples with screen output.

Section 7:
** Column descriptions for Build CSV sheet **

------------------------------------------------------------------------------------------------------
|	Column Title          |				Description					  |	Accepted Value(s)	|				Remarks    				 |
------------------------------------------------------------------------------------------------------
| S.No				          |	Serial Number of LPAR list	|		integer					|		required field				 |
------------------------------------------------------------------------------------------------------
|	lpar_name		          |	Name of LPAR / VM					  |		VM name					|		required field				 |
------------------------------------------------------------------------------------------------------
|	image				          |	Image to be used for deploy	|		Image name			|		Image must be existing |
------------------------------------------------------------------------------------------------------
|	spec_type		          |	Specification Type          | openstack (or)    | use compute template     |
|                       |                             | powervm			      | use advanced LPAR specs  |
------------------------------------------------------------------------------------------------------
|	compute_template      |	Compute Template (Flavor)   |		Flavor name			|	required when spec_type  |
|                       |                             |                   | is openstack             |
------------------------------------------------------------------------------------------------------
|	additional_disk_file  |	File Name to provide specs 	|		none (or) 	    |	none: no additional disk |
|                       |  for additional disks       |   File name       |                          |
------------------------------------------------------------------------------------------------------
|	network_name				  |	Name of the network 		    |		string					| network must be existing |
------------------------------------------------------------------------------------------------------
|	ip_address					  |	IP Address for the LPAR	    |	auto (or)         | IP picked from ip pool   |  
|                       |                             | valid IP address  |	User specified IP		     |
------------------------------------------------------------------------------------------------------
|	desired_ec					  |	Desired Entitled Capacity		|	floating point    | required when spec_type  |
|                       |                             | number	          |	is powervm				       |
------------------------------------------------------------------------------------------------------
|	desired_vcpu				  |	Desired Virutal CPU					|		integer					|	required when spec_type  |
|                       |                             |                   | is powervm               |
------------------------------------------------------------------------------------------------------
|	desired_mem					  |	Desired Memory (MB)					|		integer					|	required when spec_type  |
|                       |                             |                   | is powervm               |
------------------------------------------------------------------------------------------------------
|	min_ec						    |	Minimum Entitled Capacity	  |	floating point 		|	required when spec_type  |
|				  				      |											        |	number						| is powervm						   |
------------------------------------------------------------------------------------------------------
|	max_ec						    |	Maximum Entitled Capacity		|	floating point 		|	required when spec_type  |
|				  				      |											        | number						| is powervm						   |  
------------------------------------------------------------------------------------------------------
|	min_vcpu					    |	Minimum Virtual CPU					|		integer					|	required when spec_type  |
|				  				      |											        |										|	is powervm					     |
------------------------------------------------------------------------------------------------------
|	max_vcpu					    |	Maximum Virtual CPU					|		integer					|	required when spec_type  |
|				  				      |											        |										|	is powervm					     |
------------------------------------------------------------------------------------------------------
|	shared_weight				  |	Uncapped Shared Weight			|		integer					|	required when spec_type	 |
|								        |											        |		(0 - 255)		    |	is powervm        			 |
------------------------------------------------------------------------------------------------------
|	shared_proc_pool_name |	Shared Processor Pool Name	|		string					|	required when spec_type	 |
|								        |											        |										|	is powervm				       |
------------------------------------------------------------------------------------------------------
|	min_mem						    |	Minimum Memory							|		integer					|	required when spec_type	 |
|								        |											        |										| is powervm				       |
------------------------------------------------------------------------------------------------------
|	max_mem						    |	Maximum Memory							|		intger					|	required when spec_type	 |
|								        |											        |										|	is powervm				       |
------------------------------------------------------------------------------------------------------  
|	proc_comp_mode				|	Processor Compatibility Mode|		string					|	required when spec_type  |
|								        |											        |										|	is powervm				       |
------------------------------------------------------------------------------------------------------
|	stor_conn_grp				  |	Storage Connectivity 			  |		string					|	SCG must be supported 	 |
|								        |	Group name									|					          |	for chosen image				 |
------------------------------------------------------------------------------------------------------
|	srr_cap						    |	Simplified Remote 	        |		true or false		|	required when spec_type  |
|                       |   Restart Capability        |                   | is powervm               |
------------------------------------------------------------------------------------------------------  
|	availability_priority	|	Availability priority 			|		0 - 255					|	required when spec_type  |
|                       |   for SRR                   |                   | is powervm               |
------------------------------------------------------------------------------------------------------

Section 8:
** Column descriptions for Additional Storage CSV sheet **
------------------------------------------------------------------------------------------------------
|	Column Title          |				Description					  |	Accepted Value(s)	|				Remarks    				 |
------------------------------------------------------------------------------------------------------
|	lpar_name					    |	VM name for which disks 		|		string					|	required field				   |           
------------------------------------------------------------------------------------------------------
| num_of_disks				  |	Number of Disks         		|		Integer					|	required field				   |
------------------------------------------------------------------------------------------------------
|	disk_size_1					  |	Size for additional 		  	|		Size in GB			|	required field				   |
|                       | disk number 1               |                   |                          |
------------------------------------------------------------------------------------------------------
|	storage_template_1		|	Storage template name 	    |		string					|	required field				   |
------------------------------------------------------------------------------------------------------
|	multi_attach_1				|	Multi Attach property 		 	|		true or false		|	required field				   |
------------------------------------------------------------------------------------------------------
If more than one disk to be attached:
  define disk_size_2, storage_template_2, multi_attach_2
				 disk_size_3, storage_template_3, multi_attach_3 and so on..

Scetion 9:
** Changes **
  * v1.0.3 *
  1) Supports multiple disk attachments during the time of deploy, as part of the Build CSV Sheet
	2) Supports adding multiple disks to existing Virtual Machines
	3) Provides a better method to do SSL authentication with PowerVC server
	4) powervm spec_type now supports providing Availability Priority in the CSV file
	5) Better error handling
	6) Other bug fixes and minor enhancements
  * v1.0.2 *
	1) Build operation now allows user to specify either of two types of specs in the spec_type column.
		spec_type: powervm or openstack.
		If the spec_type is openstack, then there must be a flavor(compute template) name mentioned for the VM to be deployed.
		If the spec_type is powervm, then the flavor name is ignored, but the VM specs are taken from other respective columns.
		The tool allows user to have a mix of openstack and powervm spec_types in the same csv file.
	2) Tool is also delivered in a Docker container image.
		The tool is present under the /powervc_csv directory in the container.
	3) The 'query image' operation now displays the list of 'Storage Connectivity Group' supported by each image.
	4) Action argument gets a short hand, for example q means query, r means report
	5) Action and Resource arguments are now case insensitive

Section 10:
** Author **

		Harihara Balakrishnan
		harihara@sg.ibm.com
