#!/bin/bash
# 全局的退出信号
exit_flag=0
# 单一test的退出信号
current_test_pass_flag=0
IFS=$'\n' #这个必须要，否则会在文件名中有空格时出错
# ------------------------------------------------
# 系统化进行ut-test: 指定ut-folder下面的*._test.lua文件全部参与
# ------------------------------------------------
function u_test() {
    echo UT Test Loaded: $1
    result=`lua $1 | tail -2`
    # result="Ran 1 tests in 0.081 seconds, 0 success, 1 failures"
    failure_cnt=`echo $result | grep -Eo "[0-9]+\ failure" | grep -Eo "[0-9]+"`
    error_cnt=`echo $result | grep -Eo "[0-9]+\ error" | grep -Eo "[0-9]+"`

    if ([ "$failure_cnt" != "" ] && [ "$failure_cnt" != 0 ]) || \
        ([ "$error_cnt" != "" ] && [ "$error_cnt" != 0 ]); then
        current_test_pass_flag=1
        exit_flag=$current_test_pass_flag
        echo $result
        echo UT Test Failed: $1
        echo "-------------------------------------------"
    else
        echo UT Test Passed: $1
        echo "-------------------------------------------"
    fi
}
# ------------------------------------------------
# 系统化进行mt-test: 指定mt-folder下面的*._test.lua文件全部参与
# ------------------------------------------------
function parse_aibaby_result() {
    mapfile -t StringArray <<< $1
    length=${#StringArray[@]}
    # get last line from python stdout
    final_mark=${StringArray[$length-1]}
    if [ "$final_mark" != "success" ]; then
        # print result line by line
        for val in "${StringArray[@]}"; do
            echo $val
        done
        current_test_pass_flag=1
    fi
}

function m_test() {
    echo MT Test Loaded: $1
    head -n 50 $1 > output.log
    lua $1 >> output.log

    current_test_pass_flag=$?
    exit_flag=$?

    if [ $? -eq 0 ]; then
        res=`python3 $PYTHON_PATH output.log`
        parse_aibaby_result "$res"
        if [ "$current_test_pass_flag" == 0 ]; then
            echo MT Test Passed: $1
            echo "-------------------------------------------"
        else
            exit_flag=$current_test_pass_flag
            echo "MT Test Failed (Log check error):" $1
            echo "-------------------------------------------"
        fi
    else
        echo "MT Test Failed (Execute error):" $1
        echo "-------------------------------------------"
    fi
}
# ------------------------------------------------
# 系统化进行 budget limit policy test
# ------------------------------------------------
function b_test() {
    lua $1 > output.log

    current_test_pass_flag=$?
    exit_flag=$?
    if [ $? -eq 0 ]; then
        res=`python3 $B_PYTHON_PATH output.log`

        if [ "$res" == "success" ]; then
            echo Budget Test Passed: $1
        else
            echo $res
            current_test_pass_flag=1
            exit_flag=1
            echo "Budget Test Failed (Log check error):" $1
        fi
    else
        echo "Budget Test Failed (Execute error):" $1
    fi
}

function run_test(){
    current_test_pass_flag=0
    if [ "$1" == "mt" ]; then
        m_test $2
    elif [ "$1" == "ut" ]; then
        u_test $2
    elif [ "$1" == "bt" ]; then
        b_test $2
    else
        echo "Param should be: mt/ut/bt file_path"
    fi
}
function traverse(){
    if [ ! -d $2 ]
    then
        run_test $1 $2
        return
    fi

    for file in `ls $2`
    do
        local path=$2"/"$file
        if [ -d $2"/"$file ]
        then
            traverse $1 $path
        else
            local name=$file
            if [[ $name =~ .*_test.lua ]];
            # if [[ $name =~ eat.lua ]];
            then
                run_test $1 $path
            fi
        fi
    done
}

# # recursion list files within folder "test"
# # https://blog.csdn.net/weixin_30765505/article/details/99455706?spm=1001.2101.3001.6650.10&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-10-99455706-blog-62036883.pc_relevant_3mothn_strategy_and_data_recovery&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-10-99455706-blog-62036883.pc_relevant_3mothn_strategy_and_data_recovery&utm_relevant_index=11
# function uttest(){
#     if [ ! -d $1 ]
#     then
#         u_test $1
#         return 1
#     fi

#     for file in `ls $1`
#     do
#         if [ -d $1"/"$file ]
#         then
#             uttest $1"/"$file
#         else
#             local path=$1"/"$file
#             local name=$file
#             if [[ $name =~ .*_test.lua ]]; then
#             # if [[ $name =~ tool_test.lua ]]; then
#                 u_test $path
#             fi
#         fi
#     done
# }


# # ------------------------------------------------
# # 系统化进行mt-test: 指定mt-folder下面的*._test.lua文件全部参与
# # ------------------------------------------------
# # 全局test的退出信号
# exit_flag=0
# # 单一test的退出信号
# current_test_pass_flag=0
# function parse_aibaby_result() {
#     mapfile -t StringArray <<< $1
#     length=${#StringArray[@]}
#     # get last line from python stdout
#     final_mark=${StringArray[$length-1]}
#     if [ "$final_mark" != "success" ]; then
#         # print result line by line
#         for val in "${StringArray[@]}"; do
#             echo $val
#         done
#         current_test_pass_flag=1
#     fi
# }

# function m_test() {
#     head -n 50 $1 > output.log
#     lua $1 >> output.log

#     if [ $? -eq 0 ]; then
#         res=`python3 $PYTHON_PATH output.log`
#         parse_aibaby_result "$res"
#         if [ "$current_test_pass_flag" == 0 ]; then
#             echo MT Test Passed: $1
#             echo "-------------------------------------------"
#         else
#             echo MT Test Failed: $1
#             exit_flag=1
#             echo "-------------------------------------------"
#         fi
#     else
#         current_test_pass_flag=1
#         exit_flag=1
#         echo MT Test Failed: $1
#         echo "-------------------------------------------"
#     fi
# }
# function mttest(){
#     if [ ! -d $1 ]
#     then
#         current_test_pass_flag=0
#         m_test $1
#         if [ "$exit_flag" == 1 ] || [ "$current_test_pass_flag" == 1 ]; then
#             return 1
#         else
#             return 0
#         fi
#     fi

#     for file in `ls $1`
#     do
#         if [ -d $1"/"$file ]
#         then
#             mttest $1"/"$file
#         else
#             local path=$1"/"$file
#             local name=$file
#             if [[ $name =~ .*_test.lua ]];
#             # if [[ $name =~ eat.lua ]];
#             then
#                 current_test_pass_flag=0
#                 m_test $path
#             fi
#         fi
#     done
# }
# # ------------------------------------------------
# # 系统化进行 budget limit policy test
# # ------------------------------------------------
# function b_test() {
#     lua $1 > output.log

#     if [ $? -eq 0 ]; then
#         res=`python3 $B_PYTHON_PATH output.log`

#         if [ "$res" == "success" ]; then
#             echo Budget Test Passed: $1
#         else
#             echo $res
#             exit_flag=1
#             echo Budget Test Failed: $1
#         fi
#     else
#         exit_flag=1
#         echo Budget Test Failed: $1
#     fi
# }
# function budgetTest(){
#     if [ ! -d $1 ]
#     then
#         b_test $1
#         if [ "$exit_flag" == 1 ] || [ "$current_test_pass_flag" == 1 ]; then
#             return 1
#         fi
#     fi

#     for file in `ls $1`
#     do
#         if [ -d $1"/"$file ]
#         then
#             b_test $1"/"$file
#         else
#             local path=$1"/"$file
#             local name=$file
#             if [[ $name =~ .*_test.lua ]];
#             then
#                 b_test $path
#             fi
#         fi
#     done
# }
# ------------------------------------------------
# 系统化进行 aibaby test
# ------------------------------------------------
function aibaby_test() {
    echo "=========test/aibaby/uvnode_test.lua========="
    current_test_pass_flag=0
    res=`python3 test/run_aibaby.py outputb.log test/aibaby/uvnode_test.lua test/aibaby/pg.json`
    parse_aibaby_result "$res"
    if [ "$current_test_pass_flag" == 1 ]; then
        exit_flag=1
        echo AiBaby Test Failed: test/aibaby/uvnode_test.lua
    else
        echo AiBaby Test Passed
    fi

    echo "=========test/aibaby/uvnode_dfs_test.lua========="
    current_test_pass_flag=0
    res=`python3 test/run_aibaby.py outputd.log test/aibaby/uvnode_dfs_test.lua test/aibaby/pg.json`
    parse_aibaby_result "$res"
    if [ "$current_test_pass_flag" == 1 ]; then
        exit_flag=1
        echo AiBaby Test Failed: test/aibaby/uvnode_dfs_test.lua
    else
        echo AiBaby Test Passed
    fi

    echo "=========test/aibaby/uvnode_dfs_full_path_choose_test.lua========="
    current_test_pass_flag=0
    res=`python3 test/run_aibaby.py outputd2.log test/aibaby/uvnode_dfs_full_path_choose_test.lua test/aibaby/pg.json`
    parse_aibaby_result "$res"
    if [ "$current_test_pass_flag" == 1 ]; then
        exit_flag=1
        echo AiBaby Test Failed: test/aibaby/uvnode_dfs_full_path_choose_test.lua
    else
        echo AiBaby Test Passed
    fi
}

function single_aibaby_blocks_test() {
    pg_json_file=$1
    pl_log_file=$2
    max_cost_time=$3
    current_test_pass_flag=0

    uvnode_test_file="test/aibaby_blocks/uv_stack_blocks.lua"
    out_file="output.log"
    echo "========= ${uvnode_test_file} ========="
    echo "pg_json_file: ${pg_json_file}"
    python3 test/aibaby_blocks/check_block_res.py ${uvnode_test_file} ${pg_json_file} ${pl_log_file} ${max_cost_time} > ${out_file}
    res=`cat ${out_file}`
    parse_aibaby_result "$res"
    if [ "$current_test_pass_flag" == 1 ]; then
        exit_flag=1
        echo AiBaby Test Failed: ${uvnode_test_file} ${pg_json_file}
    else
        echo AiBaby Test Passed
    fi
}

function aibaby_blocks_test() {
    single_aibaby_blocks_test "test/aibaby_blocks/data/simple_case.json" "../test_simple_case.log" 120
    # single_aibaby_blocks_test "test/aibaby_blocks/data/hard_case.json"  "../test_hard_case.log" 150
}

function aibaby_all_test() {
    uvnode_test_file="test/aibaby_blocks/uv_all.lua"
    out_file="output_all.log"
    pg_json_file="test/aibaby_blocks/data/hard_case.json"
    pl_log_file="../test_aibaby_all.log"
    max_cost_time=240

    echo "========= ${uvnode_test_file} ========="
    echo "pg_json_file: ${pg_json_file}"

    python3 test/aibaby_blocks/check_all_res.py ${uvnode_test_file} ${pg_json_file} ${pl_log_file} ${max_cost_time} > ${out_file}
    res=`cat ${out_file}`
    parse_aibaby_result "$res"
    if [ "$current_test_pass_flag" == 1 ]; then
        exit_flag=1
        echo AiBaby Test Failed: ${uvnode_test_file} ${pg_json_file}
    else
        echo AiBaby Test Passed
    fi
}
# ------------------------------------------------
# 系统化进行 tom-mark test
# ------------------------------------------------
function parse_tom_result() {
    # if [ -z "$1" ]; then
    #     echo Tom-Mark Test Passed!
    # else
    #     mapfile -t StringArray <<< $1
    #     length=${#StringArray[@]}

    #     # get last line from python stdout
    #     if [[ $length -gt 0 ]]; then
    #         for val in "${StringArray[@]}"; do
    #             echo $val
    #         done
    #         current_test_pass_flag=1
    #     fi
    # fi
    mapfile -t StringArray <<< $1
    # length=${#StringArray[@]}
    # for val in "${StringArray[@]}"; do
    for (( idx=${#StringArray[@]}-1 ; idx>=0 ; idx-- )) ; do
        if [ "${StringArray[idx]}" == "success" ]; then
            echo Tom-Mark Test Passed!
            break
        else
            echo "${StringArray[idx]}"
            current_test_pass_flag=1
        fi
    done
}
function tom_test() {
    echo "========= test tom-mark case ========="
    current_test_pass_flag=0

    python3 test/tom_mark/run_mark.py 2>&1 > mark.log
    msg=$(cat mark.log | grep -v "HTTP")
    parse_tom_result "$msg"
    if [ "$current_test_pass_flag" == 1 ]; then
        exit_flag=1
        echo Tom-Mark Test Failed! Check mark.log
    fi
}

# 如果沒有傳參 -- 跑所有test
if [[ $# -eq 0 ]]; then
    echo "========================== aibaby test =========================="
    aibaby_test

    # "========================== aibaby block test =========================="
    aibaby_blocks_test

    # "========================== aibaby_all_test =========================="
    aibaby_all_test

    echo "========================== tom mark test =========================="
    tom_test

    echo "========================== ut test =========================="
    UT_TEST_PATH="test/ut";
    # uttest $UT_TEST_PATH
    traverse "ut" $UT_TEST_PATH

    echo "========================== mt test =========================="
    MT_TEST_PATH="test/mt"
    PYTHON_PATH="test/mtTest.py"
    # mttest $MT_TEST_PATH
    traverse "mt" $MT_TEST_PATH

    echo "========================== budget test =========================="
    B_TEST_PATH="test/budget_limit/runtime_time_limit_test.lua"
    B_PYTHON_PATH="test/budgetTest.py"
    # budgetTest $B_TEST_PATH
    traverse "bt" $B_TEST_PATH
fi

usage() {
  # 參數匹配錯誤時候調用  1>&2 标准错误输出
  echo "Usage: ${0}
        [u]           default ut test
        [m]           default mt test
        [-u|--ut]     user defined ut test
        [-m|--mt]     user defined mt test
        [-um|--mu]    default ut+mt test
        [-a|--aibaby] aibaby test
        [-b|--budget] budget test
        [-t|--tom] tom test" 1>&2
  exit 1
}
while [[ $# -gt 0 ]];do
    key=${1}
    case ${key} in
        -a|--aibaby)
            if [[ ${2} -eq 1 ]]; then
                echo "=========test/aibaby/uvnode_test.lua========="
                current_test_pass_flag=0
                res=`python3 test/run_aibaby.py outputb.log test/aibaby/uvnode_test.lua test/aibaby/pg.json`
                parse_aibaby_result "$res"
                if [ "$current_test_pass_flag" == 1 ]; then
                    echo AiBaby Test Failed: test/aibaby/uvnode_test.lua
                    exit 1
                else
                    echo AiBaby Test Passed
                fi
                shift 2
            elif [[ ${2} -eq 2 ]]; then
                echo "=========test/aibaby/uvnode_dfs_test.lua========="
                current_test_pass_flag=0
                res=`python3 test/run_aibaby.py outputd.log test/aibaby/uvnode_dfs_test.lua test/aibaby/pg.json`
                parse_aibaby_result "$res"
                if [ "$current_test_pass_flag" == 1 ]; then
                    echo AiBaby Test Failed: test/aibaby/uvnode_dfs_test.lua
                    exit 1
                else
                    echo AiBaby Test Passed
                fi
                shift 2
            elif [[ ${2} -eq 3 ]]; then
                echo "=========test/aibaby/uvnode_dfs_full_path_choose_test.lua========="
                current_test_pass_flag=0
                res=`python3 test/run_aibaby.py outputd2.log test/aibaby/uvnode_dfs_full_path_choose_test.lua test/aibaby/pg.json`
                parse_aibaby_result "$res"
                if [ "$current_test_pass_flag" == 1 ]; then
                    echo AiBaby Test Failed: test/aibaby/uvnode_dfs_full_path_choose_test.lua
                    exit 1
                else
                    echo AiBaby Test Passed
                fi
                shift 2
            elif [[ ${2} -eq 4 ]]; then
                # echo "=========test/aibaby_blocks/uvnode_test.lua========="
                aibaby_blocks_test
                shift 2
            elif [[ ${2} -eq 5 ]]; then
                # echo "=========test/aibaby_blocks/uvnode_test.lua========="
                aibaby_all_test
                shift 2
            else
                aibaby_test
                aibaby_blocks_test
                aibaby_all_test
                shift
            fi
        ;;
        -u|--ut)
            UT_TEST_PATH=${2}
            # uttest $UT_TEST_PATH
            traverse "ut" $UT_TEST_PATH
            shift 2
        ;;
        -m|--mt)
            MT_TEST_PATH=${2}
            PYTHON_PATH="test/mtTest.py"
            # mttest $MT_TEST_PATH
            traverse "mt" $MT_TEST_PATH
            shift 2
        ;;
        m)
            MT_TEST_PATH="test/mt"
            PYTHON_PATH="test/mtTest.py"
            # mttest $MT_TEST_PATH
            traverse "mt" $MT_TEST_PATH
            shift
        ;;
        u)
            UT_TEST_PATH="test/ut"
            # uttest $UT_TEST_PATH
            traverse "ut" $UT_TEST_PATH
            shift
        ;;
        -um|-mu)
            UT_TEST_PATH="test/ut"
            # uttest $UT_TEST_PATH
            traverse "ut" $UT_TEST_PATH
            MT_TEST_PATH="test/mt"
            PYTHON_PATH="test/mtTest.py"
            # mttest $MT_TEST_PATH
            traverse "mt" $MT_TEST_PATH
            shift
        ;;
        -b|--budget)
            B_TEST_PATH="test/budget_limit/runtime_time_limit_test.lua"
            B_PYTHON_PATH="test/budgetTest.py"
            # budgetTest $B_TEST_PATH
            traverse "bt" $B_TEST_PATH
            shift
        ;;
        -t|--tom)
            if [[ ${2} -eq 1 ]]; then
                tom_test
                shift 2
            else
                tom_test
                shift
            fi
        ;;
        *)
            usage
            shift
        ;;
    esac
done

if [ "$exit_flag" == 1 ] || [ "$current_test_pass_flag" == 1 ]; then
    echo "==============Test_failed=============="
    exit 1
else
    echo "==============Test_passed=============="
    exit 0
fi
