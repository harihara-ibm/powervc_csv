#!/bin/bash

# query tests

function query_tests {

echo "Test for Executing Query VMs"
./powervc_csv.rb query vms

echo "Test for Executing Query Flavors"
./powervc_csv.rb query flavors

echo "Test for Executing Query Volumes"
./powervc_csv.rb query volumes

echo "Test for Executing Query Networks"
./powervc_csv.rb query networks

echo "Test for Executing Query Host Groups"
./powervc_csv.rb query host_groups

echo "Test for Executing Query Images"
./powervc_csv.rb query images

echo "Test for Executing Query Storage Templates"
./powervc_csv.rb query storage_templates

echo "Test for Executing Query Projects"
./powervc_csv.rb query projects

echo "Test for Executing Query Storage Providers"
./powervc_csv.rb query storage_providers

echo "Test for Executing Query Fabrics"
./powervc_csv.rb query fabrics

echo "Test for Executing Query SCG"
./powervc_csv.rb query scg

echo "Test for Executing Query All"
./powervc_csv.rb query all
}
# report tests

function report_tests {
echo "Test for Executing Report VMs"
./powervc_csv.rb report vms

echo "Test for Executing Report Flavors"
./powervc_csv.rb report flavors

echo "Test for Executing Report Networks"
./powervc_csv.rb report networks

echo "Test for Executing Report Volumes"
./powervc_csv.rb report volumes

echo "Test for Executing Report Storage Templates"
./powervc_csv.rb report storage_templates

echo "Test for Executing Report Storage Providers"
./powervc_csv.rb report storage_providers

echo "Test for Executing Report SCG"
./powervc_csv.rb report scg

echo "Test for Executing Report All"
./powervc_csv.rb report all

}

function add_lpar {
	echo "Test for Building LPARs"
	./powervc_csv.rb build csv/lpar_build_sample.csv
}

function add_storage {
	echo "Test for Adding Storage"
	./powervc_csv.rb add-storage csv/volumes_add_sample.csv
}

function delete_lpar {
	echo "Test for Deleting LPARs"
	./powervc_csv.rb delete lparnew1,lparnew2,lparnew3,lparnew4
}


case $1 in 
	query) query_tests
				 ;;
	report) report_tests
					;;
	add_lpar) add_lpar
						;;
	add_storage) add_storage
							 ;;
  delete_lpar) delete_lpar
							 ;;
	all)	query_tests
				report_tests
				add_lpar
				add_storage
				delete_lpar
				;;
esac 
