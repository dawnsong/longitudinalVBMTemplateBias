#! /bin/bash
#
# dofnirt.sh
#% Init: 2020-04-20 23:46
#% Version: 2020-04-20 23:46
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

in=$1
fin=$(basename $1)
ref=$2
out=${3:-${fin%%.*}-${ref%%.*}}

export FSLOUTPUTTYPE=NIFTI_GZ

#fnirt --config=/home/songx4/dawn/bin/fnirt.inia19.conf --ref=subj0-mean.nii.gz --refmask=inia19-brainmsk.nii.gz --in=./subj0-t0.nii.gz --inmask=inia19-brainmsk.nii.gz --iout=subj0-t0-nl.nii.gz --cout=subj0-t0-nl_warp.field.nii.gz --jout=jac.subj0-t0-nl.nii.gz -v 2>&1 > fnirt.subj0-t0-nl.log &
#plRunCmd -f ${out}.nii.gz -- fnirt --config=/home/songx4/dawn/bin/fnirt.inia19.conf --ref=$ref --refmask=inia19-brainmsk.nii.gz --in=$in  --inmask=inia19-brainmsk.nii.gz --iout=${out}.nii.gz --cout=${out}_warp.field.nii.gz --jout=jac.${out}.nii.gz -v 2>&1 |tee fnirt.${out}.log
plRunCmd -f ${out}.nii.gz -- mri_robust_register --dst $ref --maskdst inia19-brainmsk.nii.gz --mov $in  --maskmov inia19-brainmsk.nii.gz --mapmov ${out}.nii.gz --lta ${out}.lta --satit --affine 2>&1 |tee flirt.${out}.log
tkregister2 --noedit --mov $in --targ $ref --reg ${out}.lta --fslregout ${out}.omat

