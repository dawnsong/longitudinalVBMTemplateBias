#! /bin/bash
#
# mkSubj.sh
#% Init: 2020-04-20 17:04
#% Version: 2020-04-20 17:04
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
        -t|'--time-points') TIME_POINTS=$2 ; shift 2 ;;
        -n|'--subject-count') SUBJECT_COUNT=$2 ; shift 2 ;;
        -sa|--scale-age) SCALE_AGE=$2; shift 2;;
        -ss|--scale-subj) SCALE_SUBJ=$2; shift 2;;
        --no-*) key=${1#--no-}; eval "DO${key^^}=0"; shift ;;
        --version) usage;;
        '-*') elog 'Unknown parameters'; usage; ;;
        *) break ;;
    esac
done
verbose=${VERBOSE:-0} ;  test 0 -ne $verbose && set -x
TIME_POINTS=${TIME_POINTS:-6}

roi=lputamen.nii.gz
scale4age=${SCALE_AGE:-0.1}
scale4subj=${SCALE_SUBJ:-0.1}

#make I_age intensity values
I[0]=0.1
ageV=`echo "scale=3; (1.0-${I[0]})/(${TIME_POINTS}-1)" |bc`
for t in $(seq 1 ${TIME_POINTS}); do 
    I[$t]=$(echo "${I[0]}+($t -1)*$ageV"|bc)
done
let tp=${TIME_POINTS}-1
let np=${SUBJECT_COUNT:-10}-1

#read tmin tmax<<<$(3dBrickStat -min -max -slow inia19-t1-brain.nii.gz)
for t in $(seq 0 $tp); do 
    let tp=t+1
    for i in $(seq 0 $np); do 
        mkEpsilon.sh epsilon4age.nii
        mkEpsilon.sh epsilon4subj.nii
        #I=I$t
        3dcalc -a $roi -b  epsilon4age.nii -c epsilon4subj.nii -expr 'step(a)*('${I[$tp]}' + '${scale4age}'*b +'${scale4subj}'*c ) +d*step(1-a) ' -d inia19-t1-brain2p.nii.gz -prefix subj${i}-t${t}.nii.gz -overwrite
    done
done

rm -f epsilon*.nii
