email_file=`echo $1`
echo enter MTA Address
read mta
echo enter Sender domain I.E. domain.com
read domain_name
echo Enter Sender name I.E. jim.brown
read user
echo enter Subject
read subject
echo enter Recipient domain I.E. somecompany.com
read to_domain
echo enter Recipient name I.E. some.body
read to_user
#echo enter attachment name
#read email_file
echo one line of body
read body
echo $body > /tmp/body
mailx -S smtp=$mta -a "./$email_file" -r $user@$domain_name -s "$subject" -v $to_user@$to_domain < /tmp/body
