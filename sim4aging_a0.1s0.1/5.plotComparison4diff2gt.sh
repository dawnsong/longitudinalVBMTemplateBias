#! /bin/bash
#
# plotComparison.sh
#% Init: 2020-04-23 01:32
#% Version: 2020-04-23 01:32
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


matlabj <<eom
m=dlmread('tAges-mean_diff2gt.log', '',1) %ignore 1st line, the header
s=dlmread('tAges-sigma_diff2gt.log', '', 1)
%set(groot, 'defaultLineLineWidth',2.0)
set(groot, 'defaultErrorBarLineWidth',2.0)
hf=figure;  hold on
%set(hf, 'DefaultLineLineWidth', 2)
ha=gca;
x1=1:size(m,1);
x2=x1+0.1; 
he1=errorbar(x1, m(:,1), s(:,1));
he2=errorbar(x2, m(:,2), s(:,2));

%hl=plot(x1, diff(:,1), '-o', x1, diff(:,2), '-x')
yline(0, '--', 'DisplayName', '')

%ha.LineWidth=2;
%hl(1).LineWidth=2;hl(2).LineWidth=2;
he1.LineWidth=2; he2.LineWidth=2;% he3.LineWidth=2;
%legend('Ground-truth', 'Age-specific Template', 'Subject-specific Template', 'Location', 'northwest')
legend('Age-specific Template Estimation', 'Subject-specific Template Estimation', 'Location', 'northwest')
xlabel('Pseudo-Ages')
ylabel('Gray Matter Density difference with ground-truth')
print -dpng cmpAgeSubjSpecificTemplate4diff2gt-wErrBars.png
eom
