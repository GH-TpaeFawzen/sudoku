#!/bin/sh

#
# Anand Avati <avati@gluster.com>
#

problem="7 0 0  0 9 0  0 0 3
         0 0 5  8 0 2  6 0 0
         0 8 0  3 0 1  0 9 0

         0 5 0  7 0 4  0 1 0
         3 0 0  0 0 0  0 0 4
         0 4 0  5 0 9  0 8 0

         0 2 0  9 0 8  0 5 0
         0 0 9  6 0 7  4 0 0
         5 0 0  0 2 0  0 0 8";

space=;


display9()
{
    echo " ==== Sudoku ===="

    for ((i=0; $i < 9; i++)); do
        for ((j=0; $j < 9; j++)); do
            idx=$(($i * 9 + $j + 1));
            printf " "
            printf "${space[$idx]}"
        done
        echo
    done
}


initialize()
{
    for ((i=0; $i < 9; i++)); do
        for ((j=0; $j < 9; j++)); do
            idx=$(($i * 9 + j + 1));
            space[$idx]="1 2 3 4 5 6 7 8 9";
        done
    done
}


fix_if_necessary()
{
    local i;
    local j;
    local idx;

    i=$1;
    j=$2;
    val=$3;

    idx=$(($i * 9 + $j + 1));

    set ${space[$idx]};

    case $# in (1)
        fix_position $i $j $1;;
    esac
}


not_possible()
{
    local i;
    local j;
    local val;
    local idx;
    local v;

    i=$1;
    j=$2;
    val=$3;
    new=;

    idx=$(($i * 9 + $j + 1));

    set ${space[$idx]};

#    echo "Unsetting from $i,$j ($@) => $val";

    case $# in (1)
        case $1 in ($val)
            echo "ERROR !! $i,$j had $1, but now unsetting $val"
            exit 1;;
        esac
        return;
    esac

    for v in $@; do
        case $v in ($val) continue;; esac
        new="$new $v";
    done

#    echo "Setting to $i,$j => ($new)";
    space[$idx]="$new";

    fix_if_necessary $i $j;
}


spread_vertical_awareness()
{
    local i;
    local j;
    local val;
    local k;

    i=$1;
    j=$2;
    val=$3;

    for ((k=0; $k < 9; k++)); do
        case $k in ($i) continue;; esac
        not_possible $k $j $val;
    done
}


spread_horizontal_awareness()
{
    local i;
    local j;
    local val;
    local k;

    i=$1;
    j=$2;
    val=$3;

    for ((k=0; $k < 9; k++)); do
        case $k in ($j) continue;; esac
        not_possible $i $k $val;
    done
}


function spread_block_awareness()
{
    local i;
    local j;
    local val;
    local k;
    local l;
    local myblk;

    i=$1;
    j=$2;

    val=$3;

    myblk=$(( ($i / 3) * 3 + ($j / 3)));

    for ((k=0; $k < 9; k++)); do
        for ((l=0; $l < 9; l++)); do
            blk=$(( ($k / 3) * 3 + ($l / 3)));

            case "$blk" in ($myblk) :;; (*) continue;; esac

            case "$k:$l" in ("$i:$j") continue;; esac
            not_possible $k $l $val;
        done
    done
}


spread_awareness()
{
    spread_vertical_awareness "$@";
    spread_horizontal_awareness "$@";
    spread_block_awareness "$@";
}


fix_position()
{
    local i;
    local j;
    local idx;
    local val;

    i=$1;
    j=$2;
    val=$3;

    idx=$(($i * 9 + j + 1));

#    echo "Fixing $i,$j ($idx) => $val";

    space[$idx]=$val;

    spread_awareness $i $j $val;
}


start_play()
{
    local i;
    local j;
    local idx;

    set $1;

    for ((i=0; $i < 9; i++)); do
        for ((j=0; $j < 9; j++)); do
            idx=$(($i * 9 + j + 1));
            [ ${!idx} -gt 0 ] && fix_position $i $j ${!idx};
        done
    done
}


main()
{
    initialize;

    start_play "$problem";

    display9;
}

main "$@";

