# Python yield
### 介绍
首先，如果你还没有对yield有个初步分认识，那么你先把yield看做“return”，这个是直观的，它首先是个return，普通的return是什么意思，就是在程序中返回某个值，返回之后程序就不再往下运行了。
看做return之后再把它看做一个是生成器（generator）的一部分（带yield的函数才是真正的迭代器）.

### Case-1
```
def foo():
    print("starting...")
    while True:
        res = yield 4
        print("res:",res)
g = foo()
print(next(g))
print("*"*20)
print(next(g))
```

**代码输出的结果如下：**

```
starting...
4
********************
res: None
4
```

**现在来看代码的执行顺序：**
1. 程序开始执行以后，因为foo函数中有yield关键字，所以foo函数并不会真的执行，而是先得到一个生成器g(相当于一个对象)

2. 直到调用next方法，foo函数正式开始执行，先执行foo函数中的print方法，然后进入while循环

3. 程序遇到yield关键字，然后把yield想想成return,return了一个4之后，程序停止，并没有执行赋值给res操作，此时next(g)语句执行完成，所以输出的前两行（第一个是while上面的print的结果,第二个是return出的结果）是执行print(next(g))的结果，

4. 程序执行print("*"*20)，输出20个*

5. 又开始执行下面的print(next(g)),这个时候和上面那个差不多，不过不同的是，这个时候是从刚才那个next程序停止的地方开始执行的，也就是要执行res的赋值操作，这时候要注意，这个时候赋值操作的右边是没有值的（因为刚才那个是return出去了，并没有给赋值操作的左边传参数），所以这个时候res赋值是None,所以接着下面的输出就是res:None,

6. 程序会继续在while里执行，又一次碰到yield,这个时候同样return 出4，然后程序停止，print函数输出的4就是这次return出的4.


带yield的函数是一个生成器，而不是一个函数了，这个生成器有一个函数就是next函数，next就相当于“下一步”生成哪个数，这一次的next开始的地方是接着上一次的next停止的地方执行的，所以调用next的时候，生成器并不会从foo函数的开始执行，只是接着上一步停止的地方开始，然后遇到yield后，return出要生成的数，此步就结束。
`res = yield 4`执行的次序可以拆开来看
```
res = yield 4 <=> 如下代码
yield 4
blah blah blah
res = ???
```

### Case-2
```
def foo():
    print("starting...")
    while True:
        res = yield 4
        print("res:",res)
g = foo()
print(next(g))
print("*"*20)
print(g.send(7))
```

**代码输出的结果如下：**

```
starting...
4
********************
res: 7
4
```
在这个例子中，`next(g)` 替换成了`g.send(7)`。
大致说一下send函数的概念：send是发送一个参数给res的。因为上面讲到，return的时候，并没有把4赋值给res，下次执行的时候只好继续执行赋值操作，只好赋值为None了，而如果用send的话，开始执行的时候，先接着上一次（return 4之后）执行，先把7赋值给了res,然后执行next的作用，遇见下一回的yield，return出结果后结束。
`res = yield 4`执行的次序可以拆开来看
```
res = yield 4 <=> 如下代码
yield 4
send(7)
res = 7
```
1. 程序执行g.send(7)，程序会从yield关键字那一行继续向下运行，send会把7这个值赋值给res变量

2. 由于send方法中包含next()方法，所以程序会继续向下运行执行print方法，然后再次进入while循环

3. 程序执行再次遇到yield关键字，yield会返回后面的值后，程序再次暂停，直到再次调用next方法或send方法


以上内容节选自：
>https://blog.csdn.net/mieleizhi0522/article/details/82142856/