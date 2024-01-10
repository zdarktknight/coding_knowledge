# Python package
### 1. Create pkg
被python解释器视为package需要满足的条件
1. 包含\_\_init__.py 及多个模块文件的pkg
2. 不能作为顶层模块来执行该文件中的py文件（不为主函数入口） -- **main** 方法所在的模块及其同级模块，主模块所在的文件夹不能作为package。主模块同级的package被视为顶级包**top-level-package**。
注：如果需要import顶层包更上层的包或者模块，需要将路径加入到`sys.path`当中
### 2. Import pkg
创建后可以通过 `import pkg` 来实现包的引用
### 2.1 relative import
```
ValueError: attempted relative import beyond top-level package
# 翻译：试图在顶级包之外进行相对导入

ImportError: attempted relative import with no known parent package
# 翻译：尝试相对导入，但没有已知的父包

ValueError: Attempted relative import in non-package
# 翻译：试图在非包中进行相对导入

SystemError: Parent module '' not loaded, cannot perform relative import
# 翻译：父模块'xxx'未加载，不能执行相对导入。

```
主模块的应使用绝对导入，主模块所在文件夹不会被视为package
**与主模块处在同一个文件夹的模块必须使用绝对导入**
#### 2.1.1 绝对导入
```
import fibo    # 隐式相对导入

from fibo import fibo1, fibo2    # 绝对路径导入

import fibo as fib    # 重命名

from fibo import fib as fibonacci
```
#### 2.1.2 相对导入
`.`代表当前包，`..`代表上层包，`...`代表上上层包 。。。
```
# 表示从当前文件所在package导入echo这个module
from . import echo

# 表示从当前文件所在package的上层package导入formats这个子package或者moudle
from .. import formats

# 表示从当前文件所在package的上层package导入的filters这个子package或者子module中导入equalizer
<注: 上层package而不是上层folder!!!>
from ..filters import equalizer
```
### 2.2 解决方案

### 2.2.1 ImportError: attempted relative import with no known parent package
翻译：尝试相对导入，但没有已知的父包
导致这个问题的原因： 主模块或者同级模块用到了相对导入，且引用了主模块所在包。因为主模块所在包不会被python解释器视为package，在python解释器看来主模块所在的包就是一个未知的父包，所以如果不小心以相对导入的方式引用到了，就会报with no known parent package这个错误。

####case 1: 主模块的同级模块在使用相对导入时引入了主模块所在包的案例
```
TestModule/
    ├── __init__.py    # 这个文件其实未起作用
    ├── main.py    # import brother1; print(__name__)
    ├── brother1.py # from . import brother2; print(__name__)
    └── brother2.py # print(__name__)
```
运行 main.py，运行结果如下
```
Traceback (most recent call last):

  File "/TestModule/main.py", line 1, in <module>

    import brother1

  File "/TestModule/brother1.py", line 1, in <module>

    from . import brother2

ImportError: attempted relative import with no known parent package
```

####case 2: 主模块在使用相对导入时引入了主模块所在包的案例
```
TestModule/
    ├── __init__.py    # 这个文件其实未起作用
    ├── main.py    # from . import brother1; print(__name__)
    ├── brother1.py # import brother2; print(__name__)
    └── brother2.py # print(__name__)
```
运行 main.py，运行结果如下
```
Traceback (most recent call last):

  File "/TestModule/main.py", line 1, in <module>

    from . import brother1

ImportError: attempted relative import with no known parent package
```
#### 解决方法
1. 将相对导入该成绝对导入：去掉 ‘.’ 即可
2. 将主文件 main.py 移除当前文件夹

### 2.2.1 ValueError: attempted relative import beyond top-level package
导致这个问题的原因： 主模块所在同级包的子模块在使用相对导入时引用了主模块所在包。因为主模块所在包不会被python解释器视为package，主模块的同级package被视为顶级包（也就是top-level package），所以主模块所在包其实是在python解释器解析到的顶层包之外的，如果不小心以相对导入的方式引用到了，就会报beyond top-level package这个错误。

案例
```
TestModule/

    ├── main.py # from Tom import tom; print(__name__)
    ├── __init__.py
    ├── Tom
    │   ├── __init__.py # print(__name__)
    │   ├── tom.py # from . import tom_brother; from ..Kate import kate; print(__name__)
    │   └── tom_brother.py # print(__name__) 
    └── Kate      
         ├── __init__.py # print(__name__)
         └── kate.py # print(__name__)
```
运行主函数：
```
Tom   # 这个是Tom包的__init__.py的模块名，可以看出包里的__init__.py的模块名就是包名

Tom.tom_brother

Traceback (most recent call last):

  File "/TestModule/main.py", line 1, in <module>

    from Tom import tom

  File "/TestModule/Tom/tom.py", line 2, in <module>

    from ..Kate import kate

ImportError: attempted relative import beyond top-level package
```
#### 解决方案
**方案一**：
把main.py移动到TestModule文件夹外面，使之与TestModule平级，这样TestModule即会被解析器视为一个package，在其他模块中使用相对导入的方式引用到了也不会报错。
```
src/
├── main.py # from TestModule.Tom import tom; print(__name__)
└── TestModule/
        ├── __init__.py # print(__name__)
        ├── Tom
        │   ├── __init__.py # print(__name__)
        │   ├── tom.py # from . import tom_brother; from ..Kate import kate; print(__name__)
        │   └── tom_brother.py # print(__name__) 
        └── Kate      
             ├── __init__.py # print(__name__)
             └── kate.py # print(__name__)
```
**方案二**：
tom.py中将TestModule包加入到sys.path变量中，并使用绝对导入的方式导入Kate包，修改后的tom.py内容如下：
```
from . import tom_brother

import os, sys

sys.path.append("..") # 等价于 sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from Kate import kate # 改成绝对导入的方式导入Kate

print(__name__)
```
关于为什么已经把TestModule加入了包查找路径还需要使用绝对导入来导入Kate的的解释：

从上面的运行结果可以看出，tom_brother.py的模块名还是Tom.tom_brother，模块名并没有因为把TestModule加入了包查找路径就发生改变，而相对导入是根据模块名来确定的，如果模块名中没有TestModule，那还是不能使用相对导入的方式来导入Kate，所以必须使用绝对导入的方式来导入Kate包

以上内容节选自：
>https://zhuanlan.zhihu.com/p/416867942