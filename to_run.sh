if [[  $# -eq 2 ]]; then
	sudo pip3 install MySQLdb pubmed_parser numpy scipy sklearn
	echo "Creating Database pubmed"
	mysql -u $1 "-p$2" -e "create database pubmed"	#create database automatically
	python3 db_maker.py "$1" "$2"	#parse xml and send to sql
	echo "The citation finder requires an active internet connection"
	python3 citation_finder.py "$1" "$2"	#parse xml and send to sql
	R CMD INSTALL RMySQL
	R CMD INSTALL dplyr
	echo "Now we will score all authors"
	Rscript authorScore.R "$1" "$2" 	#Score authors accoring to the order they appear in that paper
	echo "Now we will go online and learn medical words. Needs internet connection"
	python3 learn_vocab.py	#Learn medical vocabulary for finding simlar medical terms
	echo "Now you can search with using python3 search_long.py \"search_terms\""
else
	echo "requires 2 arguments, your mysql username and password, the one with create db permissions"
fi


