#! /bin/bash
#
# chkTplDiff4PseudoAges.sh
#% Init: 2020-05-21 13:36
#% Version: 2020-05-21 13:36
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

for t in $(seq 0 5); do 
    ageTpl=t${t}-mean.nii.gz
    for s in $(seq 0 9); do 
        #for tt in $(seq 0 5); do 
            subj=subj${s}-mean.nii.gz
            #subj=subj${s}-t${tt}.nii.gz
            #subj=subj${s}-t${t}.nii.gz
            #L2norm4diff.sh $ageTpl $subj
            3ddot -mask lputamen.nii.gz $ageTpl $subj
        #done
    done > age${t}.L2norm4diff.1D
    3dTstat -mean -stdev -prefix stdout: age${t}.L2norm4diff.1D\'
done |tee L2normdiff4tpl.meanSigma

#plot the tpl diff over pseudo-ages

