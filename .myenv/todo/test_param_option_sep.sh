parameters="a b c \"d -e f\" g 1 2 '1 2 3' '-4 -5' 66 -h i -j -k l 1 2 3"

options=`echo $parameters | sed -e "s/^.*\"//;s/^.*'//;s/^[^-]* -/ -/;"`	# first " -" not in "/'
echo $options
arguments=`echo $parameters | sed -e "s/$options//;"`				# remove all options
echo $arguments

