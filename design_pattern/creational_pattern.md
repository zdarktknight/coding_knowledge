# Creational pattern
1. Singleton https://refactoring.guru/design-patterns/singleton
2. Prototype https://refactoring.guru/design-patterns/prototype
克隆对象的方法，重写Object中的clone方法
用原型实例指定创建对象的种类 -- 拷贝这些原型创建新的对象
个对象的产生可以不由零起步，直接从一个已经具备一定雏形的对象克隆，然后再修改为生产需要的对象。
3. Builder https://refactoring.guru/design-patterns/builder 
4. Factory: https://refactoring.guru/design-patterns/factory-method 
   工厂模式 (Java 常用模式)
   https://blog.csdn.net/meng17332312132/article/details/116308032l
5. Abstract factory: https://refactoring.guru/design-patterns/abstract-factory 
创建一组相关/相互依赖的对象，针对多个产品等级结构
将具体产品的实体延迟到具体工厂的子类当中
抽象工厂比工厂多一层
    1. animal-factory
        1. female-factory: create-cat, create-dog
        2. male-factory: create-cat, create-dog
    2.  animal
        1. cat: female, male
        2. dog: female, male
