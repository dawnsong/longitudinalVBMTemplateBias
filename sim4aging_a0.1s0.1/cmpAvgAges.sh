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

echo > tAges.log
echo > tAges-nl.log
echo > tAges-nl-ageSpec.log
for t in $(seq 0 5); do 
    3dMean -prefix t${t}-mean.nii.gz subj*-t${t}.nii.gz 
    3dMean -prefix t${t}-mean-nl.nii.gz subj*-t${t}-nl.nii.gz 
    3dMean -prefix t${t}-mean-nl-ageSpec.nii.gz subj*-t${t}-nl-ageSpec.nii.gz

    3dROIstats -sigma -1Dformat -mask lputamen.nii.gz t${t}-mean.nii.gz  >>  tAges.log
    #subject specific template
    3dROIstats -sigma -1Dformat -mask lputamen.nii.gz t${t}-mean-nl.nii.gz  >>  tAges-nl.log
    #age specific template
    3dROIstats -sigma -1Dformat -mask lputamen.nii.gz t${t}-mean-nl-ageSpec.nii.gz  >>  tAges-nl-ageSpec.log
done

echo "#gt ageTpl subjTpl"> tAges-mean.log
echo "#gt ageTpl subjTpl"> tAges-sigma.log
1dcat tAges.log[0] tAges-nl-ageSpec.log[0]  tAges-nl.log[0] |rmComment >> tAges-mean.log
1dcat tAges.log[1] tAges-nl-ageSpec.log[1] tAges-nl.log[1] |rmComment >> tAges-sigma.log
