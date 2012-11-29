. $HOME/.server-vars.bash 			# check host and set variables

if [ -e $HOME/local/setenv.bash ]; then		# sweet, dsc-local is installed
  . $HOME/local/setenv.bash 				# run it's setenv.bash
else						# bootstrap, sunfreeware; set PATH (and PYTHONPATH for hg)
  export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/SUNWspro/bin:/usr/ccs/bin:/usr/perl5/5.8.4/bin:/cdlcommon/products/libxml2-2.5.8/bin:/usr/sfw/bin:/lib/svc/bin:/opt/SUNWspro/contrib/vim/bin:/usr/local/bin:/cdlcommon/products/bin
  export PYTHONPATH=/usr/local/lib/python2.6/site-packages
fi
curl "${BACK_SERVER}/wsgi/ois_service.wsgi?ark=ark:/13030/c88s4n09&parent_ark=ark:/13030/kt4j49r8b8" 2> /dev/null |xmllint --noout -
