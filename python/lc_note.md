## 刷刷
https://github.com/EndlessCheng/codeforces-go/blob/master/leetcode/README.md
- 子集型回溯: Q17,Q78,Q131
- 组合型回溯: LC22、LC216、LC77、LC39
- 排列型回溯: LC 46 全排列、LC 51 N皇后、Q52、Q2850(可以使用max-flow 进行计算)
- 匹配型题目: 1947、1349、LCP04覆盖、1879、2172
- 动态规划型题目: 198、70、746、377、2466、213
- 背包问题: 494、322、2915、416、518

### Lesson 08 删除链表
237, 19, 83, 82, 203

### Lesson 07 快慢指针(环形链表)
876, 141, 142, 143, 234

### Lesson 03 滑动窗口
209、3、713、2958、2730、2779、1004、2962、2302、1658、1234、76
双指针(209|713)
单调性: 满足要求 -> 不满足要求 | 满足要求 -> 不满足要求

### Lesson 20 DP 最长递增子序列
300
673、2826、1671、1964、1626、354、1187
子序列
思路1 选或者不选 需要知道上一个选择的数字
思路2 枚举选哪个 比较当前选的数字和下一个要选的数字
采用子集型回溯去思考

dfs(i) 以i结尾的LIS长度
枚举nums[j]
下一个子问题 以nums[j] 结尾的LIS的长度

### Lesson 19 DP 最长公共子序列
1143、72、300、1671、1626
583、712、97、1458、1092
子序列: 不连续
子串、子数组: 连续

思路: s, t
子序列 每个字母 选or不选 
从最后一对字母考虑，则有 2*2=4种情况
1. 当前操作？ s[i], t[j] 选or不选
2. 子问题？ s的前i个字母, t的前j个字母的LCS长度
3. 下一个子问题
    - s的前i-1个字母, t的前j-1个字母的LCS长度
    - s的前i-1个字母, t的前j个字母的LCS长度
    - s的前i个字母, t的前j-1个字母的LCS长度
dfs(i, j) = max(dfs(i-1, j), dfs(i, j-1), dfs(i-1, j-1)+(s[i]==t[j]))

当 s[i] == t[j]的时候: 一定会选择s[i], t[j] 所以 dfs(i-1, j) dfs(i, j-1) 不需要进行考虑
当 s[i] ！= t[j]的时候: LCS 的要求可以不用考虑 dfs(i-1, j-1), 因为dfs(i-1, j)/dfs(i, j-1) 包含了dfs(i-1, j-1)的结果

### Lesson 18 DP 01背包-完全背包
0-1背包问题: 至多装capacity，求方最大价值
dfs(i, c) = max(dfs(i-1, c), dfs(i-1, c-w[i])+v[i])
完全背包 (322):
物品可以重复进行选择
关键词: 至少/至多/恰好
494、322、2915、416、518
0-1背包的常见变体: 
1. 至多装capacity，求方案数/最大/最小价值
2. 恰好装capacity，求方案数/最大/最小价值
3. 至少装capacity，求方案数/最大/最小价值

Q494: 选一些数，恰好装capacity，求方案数
dfs(i, c) = dfs(i-1, c) + dfs(i-1, c-w[i])
### Lesson 17 动态规划 
也可以换成选与不选的问题
198、70、746、377、2466、213
记忆化搜索，可以转化成递推的方式
即: 将递归的function转化成数组的形式; 将recursion转化成循环

### Lesson 16 排列型回溯
LC 46 全排列
LC 51 N皇后
Q52、Q2850(可以使用max-flow 进行计算)
思路
path 记录路径上的数字
set-s 记录剩余未被选择的数字
1. 从s中枚举要访问的数字 放入path[i]
2. 构造需要排列的 >= i 的部分
3. next-question 构造 i+1 部分
dp(i, s) 
    -> dp(i+1, s-{x1})
    -> dp(i+1, s-{x2})
    ...
时间复杂度的计算
叶子数量 * 路径长度
精确计算 = 统计节点个数
A(n, 0) + A(n, 1) + A(n, 2) + ... = floor(e*n!)

### Lesson 15 组合型回溯
LC22、LC216、LC77、LC39
组合问题可以进行一些减枝的操作 
代码模板则仍可以按照Lesson-14的模板进行
-LC77 组合
-LC216 需要选择的数有限制+数字家和有限制
-LC22 括号生成问题
-LC39 组合总和

### Lesson 14 子集型回溯
Q17,Q78,Q131
从输入进行考虑: 当前的元素是否进行选择

**思路一**
从输入进行考虑: 当前的元素是否进行选择
```
# 子集型回溯
ans = []
path = []
n = len(nums)
# 采用子集型回溯

def dfs(i):
    ans.append(path.copy())
	if i == n:
		# 需要保存答案
		ans.append(path.copy())
		return

	# 当前元素不进行选择 那么直接跳过
	dfs(j+1)
	# 当前元素选择 需要加到路径当中，然后进行递归
	path.append(nums[j])
	dfs(j+1)
	# 递归结束，需要将变量回复到原来的样子
	path.pop()
dfs(0)
return ans
```
**思路二**
从输出进行考虑: 结果的i位是选择的谁
那么在递归中，操作就变成了枚举操作
```
# 子集型回溯
ans = []
path = []
n = len(nums)
# 采用子集型回溯

def dfs(i):
   	ans.append(path.copy())
   	if i == n:
        return
   	for j in range(i, n): 
        path.append(nums[j])
        dfs(j+1)
        # 递归结束，需要将变量回复到原来的样子
        path.pop()
dfs(0)
return ans
```

### Lesson 09 递归
回溯+递归
边界条件+非边界条件
将问题拆解
Q104 二叉树的最大深度
Q111 二叉树的最小深度
**思路一**
```
# Q104
def maxDepth(self, root: Optional[TreeNode]) -> int:
    if not root:
        return 0
    # 左边的最大深度
    left = self.maxDepth(root.left)
    # 右边的最大深度
    right = self.maxDepth(root.right)
    return max(left, right) + 1

```
**思路二 使用全局变量**
`nonlocal`用在嵌套函数中修改外层函数的局部变量。局部变量是函数内部定义的变量，不能被其他函数修改、访问。
嵌套函数是定义在一个函数内部的函数，他可以访问外层函数的局部变量，但是不能修改他们。如果需要修改，则需要使用关键字`nonlocal`。

```
res = 0
def dfs(node, cnt):
    if node is None:
        return 
    cnt += 1
    # 替代全局变量，需要增加关键字 nonlocal
    nonlocal res
    res = max(res, cnt)
    # 左边的最大深度
    left = dfs(node.left, cnt)

    # 右边的最大深度
    right = dfs(node.right, cnt)
dfs(root, 0)
return res
```
### Lesson 11 验证二叉树
前序遍历: 先判断、再递归: 先访问节点数值 再递归左右子树
中序遍历: 大于上一个节点
后序遍历: 先递归、再遍历

LC98 验证二叉搜索树
Sol-1 前序遍历: 将节点的范围一个个向下传递
左树成立+右树成立 -> 递归
判断条件: node.val在区间内 --> 递归的时候不断对区间进行更新 --> recursion 返回的是结果

Sol-3 后序遍历: 将节点的范围一个个向上传递
先遍历左右子树 然后将范围向上传

Sol-2 中序遍历
key-point: 中序遍历下，访问的点具有递增的特点
代码层, 需要进行遍历，然后return进行比较
递归左树 -> 访问节点数值  -> 右树 -> 严格递增
需要查看当前节点是不是大于上一个节点
LC230
LC700

