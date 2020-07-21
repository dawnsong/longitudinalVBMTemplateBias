#! /bin/bash
#
# cmpAvg.sh
#% Init: 2020-04-21 01:26
#% Version: 2020-04-21 01:26
#% Copyright (C) 2020~2020 Xiaowei.Song <dawnwei.song@gmail.com>
#% http://restfmri.net/dawnsong
# Distributed under terms of the Academy Free License (AFL) license.
#

_CALLDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CALLPROG=$(readlink -f ${BASH_SOURCE[0]})
_CALLCMD="$0 $@"
#shopt -s expand_aliases ; source $(dawnbin)/slib.stack.sh
source $(dawnbin)/slib.bash.sh
 echo "$(date) | $0 '"$@"'" >> $(basename $0).LOG
usage(){ cat 1>&2 <<eou
Usage: $(grep -m1 '#% Version:' `readlink -f ${BASH_SOURCE[0]}`)
    ${0} [options]
    options:
$(sed --silent '/case/,$p;/case/d;/esac/q' $_CALLPROG |sed -e '/sed/,/case/d; /esac/d')
eou
exit;}
if [ $# -eq 0 ]; then usage;  fi
while [ $# -gt 0 ]; do
    case "$1" in
        '-v') export VERBOSE=1 ; shift ;;
        -V|--version) usage ;;
        '--template') T1TPL=$2 ; shift 2 ;;
        --no-*) key=${1#--no-}; eval "DO${key^^}=0"; shift ;;
        --version) usage;;
        '-*') elog 'Unknown parameters'; usage; ;;
        *) break ;;
    esac
done
verbose=${VERBOSE:-0} ;  test 0 -ne $verbose && set -x

export AFNI_DECONFLICT=OVERWRITE

echo > tAges-nl_diff2gt.log
echo > tAges-nl-ageSpec_diff2gt.log
for t in $(seq 0 5); do 
    3dMean -prefix t${t}-mean.nii.gz subj*-t${t}.nii.gz 
    3dMean -prefix t${t}-mean-nl.nii.gz subj*-t${t}-nl.nii.gz 
    3dMean -prefix t${t}-mean-nl-ageSpec.nii.gz subj*-t${t}-nl-ageSpec.nii.gz

    #calculate differences 
    3dcalc -a t${t}-mean.nii.gz  -b t${t}-mean-nl.nii.gz  -expr 'b-a' -prefix t${t}-mean-nl_diff2gt.nii.gz
    3dcalc -a t${t}-mean.nii.gz  -b t${t}-mean-nl-ageSpec.nii.gz  -expr 'b-a' -prefix t${t}-mean-nl-ageSpec_diff2gt.nii.gz

    #subject specific template
    3dROIstats -sigma -1Dformat -mask lputamen.nii.gz t${t}-mean-nl_diff2gt.nii.gz  >>  tAges-nl_diff2gt.log
    #age specific template
    3dROIstats -sigma -1Dformat -mask lputamen.nii.gz t${t}-mean-nl-ageSpec_diff2gt.nii.gz  >>  tAges-nl-ageSpec_diff2gt.log
done

echo "#ageTpl subjTpl"> tAges-mean_diff2gt.log
echo "#ageTpl subjTpl"> tAges-sigma_diff2gt.log
1dcat tAges-nl-ageSpec_diff2gt.log[0]  tAges-nl_diff2gt.log[0] |rmComment >> tAges-mean_diff2gt.log
1dcat tAges-nl-ageSpec_diff2gt.log[1] tAges-nl_diff2gt.log[1] |rmComment >> tAges-sigma_diff2gt.log
