Page({
  data: {
    products: [
      {
        id: 1,
        name: '商品1',
        price: 99.00,
        image: '/images/product1.jpg',
        description: '商品1的详细描述'
      },
      // 更多商品...
    ]
  },

  onSearch: function(e) {
    const keyword = e.detail.value;
    // 实现搜索逻辑
  },

  goToDetail: function(e) {
    const productId = e.currentTarget.dataset.id;
    wx:navigateTo({
      url: `/pages/detail/detail?id=${productId}`
    });
  }
});
