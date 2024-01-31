# Python sys.settrace
### 介绍
Python sys.settrace()函数是Python标准库中的一个函数，它允许我们在debug的时候对Python代码进行跟踪，获取函数之间的调用关系、每行执行的代码等信息。
该函数可以被用于性能分析、调试、代码覆盖率、tracing/monitoring等等方面，是Python中比较重要的调试工具之一

### Case-1
```sys.settrace(frame, event, arg.frame)```

frame：frame 是当前堆栈帧
event：一个字符串，可以是'call', 'line', 'return', 'exception'或者'opcode'
arg：取决于事件类型
返回：对本地跟踪函数的引用，然后返回对自身的引用。


**使用sys.settrace()**
其中，function是一个函数，用来指定trace的行为。当Python解释器执行一行代码时，settrace函数便会调用指定的function函数来处理该行代码。
当function返回一个值时，该值决定了下一步解释器执行的动作，
如果返回None，则该行代码会继续被执行，如果返回一个"call"，则解释器会进入函数调用，
如果返回一个"return"，则表示当前函数调用已经结束。

#### 基本使用
```
import sys

def function():
    x=1
    try:
        assert 1==2
    except Exception as e:
       x=e
    return x

def trace(frame, event, arg):
    """
        frame:frame 是当前堆栈帧
        event:一个字符串，可以是'call', 'line', 'return', 'exception'或者'opcode'
        arg:取决于事件类型

            frame.f_code.co_name  执行函数名称
            frame.f_lineno   执行行号
            frame.f_locals["arr"]
    """
    print(event, frame.f_code.co_name, frame.f_lineno,"==>", frame.f_locals, arg)
    return trace

sys.settrace(trace)
function()
sys.settrace(None)
```

#### 高级使用
```
import sys
from functools import wraps


def trace_variable(variable_name):
    def decorator(func):
        change_history = []

        def trace(frame, event, arg):
            # value = frame.f_locals.get(variable_name)
            # if value not in change_history:
            #     change_history.append((value))
            print(event, frame.f_code.co_name, frame.f_lineno, frame.f_locals, arg)
            return trace

        @wraps(func)
        def inner(*args, **kwargs):
            sys.settrace(trace)
            result = func(*args, **kwargs)
            sys.settrace(None)
            return result
        return inner
    return decorator


@trace_variable('arr')
def bSort(arr):
    for i in range(len(arr) - 1):
        for j in range(len(arr) - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr


if __name__ == "__main__":
    arr = [3, 2, 1]
    bSort(arr)
```

以上内容节选自：
>https://www.cnblogs.com/shuzf/p/17201149.html
