## 刷刷
https://github.com/EndlessCheng/codeforces-go/blob/master/leetcode/README.md
### Lesson 16 排列型回溯

### Lesson 15 组合型回溯
LC22、LC216、LC77
组合问题可以进行一些减枝的操作 
代码模板则仍可以按照Lesson-14的模板进行
-LC77 组合
-LC216 需要选择的数有限制+数字家和有限制
-LC22 括号生成问题


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
