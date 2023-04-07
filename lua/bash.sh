#!/bin/env bash
cat /dev/null > stat.txt
grep -v 'to send' $1|grep -v '{'|grep @ | while read m; do
flr=`echo $m|cut -d' ' -f 2,3 |xargs -i date +%s -d "{}"`
rem=`echo $m|cut -d. -f2|cut -d' ' -f1`
if [ -z "$old" ]; then 
    old="$flr.$rem"
fi
diff=`echo $flr.$rem - $old |bc`
old="$flr.$rem"

stat=`echo $m |cut -d'@' -f1 |rev|cut -d' ' -f1|rev`
node=`echo $m |cut -d'@' -f2 |cut -d'-' -f1`
phase=`echo $m |cut -d'#' -f2`

echo "$old $diff $node $stat $phase" >> stat.txt    
done 

# sort -k3  stat.txt |cut -d' ' -f 3 |uniq -c |sort -nr |sed -e 's/^\ *//g'|sed -e 's/\ /,/g' > node_count.csv
# sort -k4  stat.txt |cut -d' ' -f 4 |uniq -c |sort -nr |sed -e 's/^\ *//g'|sed -e 's/\ /,/g' > stat_count.csv

# https://www.cnblogs.com/hider/p/11834706.html
# 统计次数
stat_file="time_stat.txt"
cat /dev/null > $stat_file
echo "phase, func, count, sum, avg, max, std" >  $stat_file
awk -F ' ' '{cnt[$5", "$4]++} {sum[$5", "$4]+=$2} {if ($2 > max[$5", "$4]) max[$5", "$4] = $2; fi} {sumsq[$5", "$4] += ($2)^2} END {for(i in cnt){printf "%s, %d, %6f, %6f, %6f, %6f \n", i, cnt[i], sum[i], sum[i]/cnt[i], max[i], sqrt((sumsq[i]-sum[i]^2/cnt[i])/cnt[i])}}' stat.txt | sort -rnk 3 >> $stat_file 

# ---------------------------------------------------------------------

#!/bin/bash
# ------------------------------------------------
# 系统化进行ut-test: 指定ut-folder下面的*._test.lua文件全部参与
# ------------------------------------------------
function u_test() {
    result=`lua $1 | tail -2`

    failure_cnt=`echo $result | grep -Eo "[0-9]+\ failure" | grep -Eo "[0-9]+"`
    error_cnt=`echo $result | grep -Eo "[0-9]+\ error" | grep -Eo "[0-9]+"`

    if ([ "$failure_cnt" != "" ] && [ "$failure_cnt" != 0 ]) || \
        ([ "$error_cnt" != "" ] && [ "$error_cnt" != 0 ]); then
        echo UT Test Failed: $1
        echo $result
        return 1
    else 
        echo UT Test Passed: $1
        return 0
    fi
}

# recursion list files within folder "test" 
# https://blog.csdn.net/weixin_30765505/article/details/99455706?spm=1001.2101.3001.6650.10&utm_medium=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-10-99455706-blog-62036883.pc_relevant_3mothn_strategy_and_data_recovery&depth_1-utm_source=distribute.pc_relevant.none-task-blog-2%7Edefault%7ECTRLIST%7ERate-10-99455706-blog-62036883.pc_relevant_3mothn_strategy_and_data_recovery&utm_relevant_index=11
function uttest(){
    if [ ! -d $1 ]
    then 
        u_test $1    
        return 1
    fi
    
    for file in `ls $1`
    do
        if [ -d $1"/"$file ]
        then
            uttest $1"/"$file
        else
            local path=$1"/"$file       
            local name=$file   
            if [[ $name =~ .*_test.lua ]]; then
            # if [[ $name =~ tool_test.lua ]]; then
                u_test $path
            fi          
        fi
    done
}
IFS=$'\n' #这个必须要，否则会在文件名中有空格时出错

# ------------------------------------------------
# 系统化进行mt-test: 指定mt-folder下面的*._test.lua文件全部参与
# ------------------------------------------------
# 全局test的退出信号
exit_flag=0
# 单一test的退出信号
current_test_pass_flag=0
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
    head -n 50 $1 > output.log
    lua $1 >> output.log

    if [ $? -eq 0 ]; then
        res=`python3 $PYTHON_PATH output.log`
        parse_aibaby_result "$res"
        if [ "$current_test_pass_flag" == 0 ]; then
            echo MT Test Passed: $1
            echo "-------------------------------------------"
        else
            echo MT Test Failed: $1
            echo "-------------------------------------------"
        fi
    else
        current_test_pass_flag=1
        echo MT Test Failed: $1
        echo "-------------------------------------------"  
    fi
}
function mttest(){
    if [ ! -d $1 ]
    then
        current_test_pass_flag=0 
        m_test $1    
        return 1
    fi 

    for file in `ls $1` 
    do
        if [ -d $1"/"$file ] 
        then
            mttest $1"/"$file
        else
            local path=$1"/"$file       
            local name=$file   
            if [[ $name =~ .*_test.lua ]]; 
            # if [[ $name =~ eat.lua ]];
            then
                current_test_pass_flag=0
                m_test $path
            fi          
        fi
    done
}
# ------------------------------------------------
# 系统化进行 budget limit policy test
# ------------------------------------------------
function b_test() {
    lua $1 > output.log

    if [ $? -eq 0 ]; then
        res=`python3 $B_PYTHON_PATH output.log`
    
        if [ "$res" == "success" ]; then
            echo Budget Test Passed: $1
        else
            echo $res
            echo Budget Test Failed: $1
        fi
    else
        echo Budget Test Failed: $1
    fi
}
function budgetTest(){
    if [ ! -d $1 ]
    then 
        b_test $1    
        return 1
    fi 

    for file in `ls $1` 
    do
        if [ -d $1"/"$file ] 
        then
            b_test $1"/"$file
        else
            local path=$1"/"$file       
            local name=$file   
            if [[ $name =~ .*_test.lua ]]; 
            then
                b_test $path
            fi          
        fi
    done
}
# ------------------------------------------------
# 系统化进行 aibaby test
# ------------------------------------------------
function aibaby_test() {
    echo "=========test/aibaby/uvnode_test.lua========="
    current_test_pass_flag=0
    res=`python3 test/run_aibaby.py outputb.log test/aibaby/uvnode_test.lua`
    parse_aibaby_result "$res"
    if [ "$current_test_pass_flag" == 1 ]; then
        exit_flag=1
        echo AiBaby Test Failed: test/aibaby/uvnode_test.lua
    else
        echo AiBaby Test Passed
    fi
    
    echo "=========test/aibaby/uvnode_dfs_test.lua========="
    current_test_pass_flag=0
    res=`python3 test/run_aibaby.py outputd.log test/aibaby/uvnode_dfs_test.lua`
    parse_aibaby_result "$res"
    if [ "$current_test_pass_flag" == 1 ]; then
        exit_flag=1
        echo AiBaby Test Failed: test/aibaby/uvnode_dfs_test.lua
    else
        echo AiBaby Test Passed
    fi
    
    echo "=========test/aibaby/uvnode_dfs_full_path_choose_test.lua========="
    current_test_pass_flag=0
    res=`python3 test/run_aibaby.py outputd2.log test/aibaby/uvnode_dfs_full_path_choose_test.lua`
    parse_aibaby_result "$res"
    if [ "$current_test_pass_flag" == 1 ]; then
        exit_flag=1
        echo AiBaby Test Failed: test/aibaby/uvnode_dfs_full_path_choose_test.lua
    else
        echo AiBaby Test Passed
    fi
}

function aibaby_blocks_test() {
    current_test_pass_flag=0
    uvnode_test_file="test/aibaby_blocks/uvnode_test.lua"
    pg_json_file="test/aibaby_blocks/owl_2_filter.json"
    out_file="output.log"

    echo "=========${uvnode_test_file}========="

    python3 test/aibaby_blocks/check_block_res.py ${uvnode_test_file} ${pg_json_file} >> ${out_file}
    res=`cat ${out_file}`
    parse_aibaby_result "$res"
    if [ "$current_test_pass_flag" == 1 ]; then
        exit_flag=1
        echo AiBaby Test Failed: ${uvnode_test_file}
    else
        echo AiBaby Test Passed
    fi
}

echo "========================== aibaby test =========================="
aibaby_test
if [ "$exit_flag" == 1 ]; then
    exit 1
fi

echo "========================== aibaby_blocks_test =========================="
aibaby_blocks_test
if [ "$exit_flag" == 1 ]; then
    exit 1
fi

echo "========================== ut test =========================="
UT_TEST_PATH="test/ut";
uttest $UT_TEST_PATH

echo "========================== mt test =========================="
MT_TEST_PATH="test/mt"
PYTHON_PATH="test/mtTest.py"
mttest $MT_TEST_PATH

echo "========================== budget test =========================="
B_TEST_PATH="test/budget_limit/runtime_time_limit_test.lua"
B_PYTHON_PATH="test/budgetTest.py"
budgetTest $B_TEST_PATH

# ---------------------------------------------------------------------
#!/bin/bash
# ------------------------------------------------
# 进行 aibaby test -- 用 pid 停止当前的进程 
# ------------------------------------------------
GAP_TIME=1
function aibabytest(){
    # create output.log 
    filePath="output_test.log"
    if [ ! -f "$filePath" ];then
        touch $filePath
        echo "文件创建完成"
    else
        echo "" > $filePath
    fi

    # get upper path
    updir=$(dirname $(pwd))
    cd $updir
    
    # run aibaby demo and process log line by line
    # lua test/test.lua | \
    lua aog/pl_run.lua aog/thirdparty/eventplugin/lib aog | \
    while read i 
    do
        #write file
        echo $i >> $updir/aog/$filePath
        pattern="to send"
        if [[ ${i} == *${pattern}* ]] 
        then
            to_send_timer=$(date "+%Y-%m-%d %H:%M:%S")
            time1=$(date +%s -d "${to_send_timer}")
        else
            current_timer=$(date "+%Y-%m-%d %H:%M:%S")
            time2=$(date +%s -d "${current_timer}")
        fi
        
        if [[ $time1 > 0 && $time1 < $time2 ]]
        then  
            duration=$(($(date +%s -d "${current_timer}")-$(date +%s -d "${to_send_timer}")));
            echo "耗时： $duration"
        fi
        
        # 如果若干时间内没有看到to-send，则退出当前脚本
        if [[ $duration -ge $GAP_TIME ]]
        then
            # kill lua process
            ps -ef | grep lua | grep -v grep | awk '{print $2}' | xargs kill -9
            break
            # exit
        fi 
    done
    echo "hello world"
}

echo "============= mt test ============="
aibabytest 