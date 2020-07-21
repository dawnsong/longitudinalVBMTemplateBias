#! /bin/bash
#
# 0.mkAvg.sh
#% Init: 2020-06-21 22:44
#% Version: 2020-06-21 22:44
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

export FSLOUTPUTTYPE=NIFTI_GZ

#subj-specific template
3dMean -overwrite -prefix mean4ageSpec.nii.gz ../subj?-t?-nl-ageSpec.nii.gz
#exit
#align averges to the population mean
#for t in $(seq 0 5); do
    #in=subj${s}-t${t}-nl-ageSpec.nii.gz
    pexec -n 10 -p "$(seq 0 5)" -e t -c -R -- 'dofnirt.sh ../t${t}-mean.nii.gz mean4ageSpec.nii.gz t${t}-mean2ageSpec'
#done

#apply all subjects aligned images another FNIRT/warping to the common space
for t in $(seq 0 5); do
    #in=subj${s}-t${t}-nl.nii.gz
    pexec -n 10 -p "$(seq 0 9)" -e i -c -R -- 'applywarp --ref=mean4ageSpec.nii.gz  --in=../subj${i}-t'${t}'-nl-ageSpec.nii.gz --out=subj${i}-t'${t}'-nl-ageSpec.nii.gz  --warp=t'${t}'-mean2ageSpec_warp.field.nii.gz'
done

#age-specific template
#3dMeat -prefix mean4subjSpec.nii ../subj?-t?-nl-ageSpec.nii.gz
    #in=subj${s}-t${t}-nl-ageSpec.nii.gz
