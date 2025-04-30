Page({
  data: {
    product: null,
    selectedDate: '',
    minDate: '',
    maxDate: ''
  },

  onLoad: function(options) {
    const productId = options.id;
    // 根据ID获取商品详情
    this.getProductDetail(productId);
    
    // 设置可选择的日期范围
    const now = new Date();
    this.setData({
      minDate: now.toISOString().split('T')[0],
      maxDate: new Date(now.setMonth(now.getMonth() + 1)).toISOString().split('T')[0]
    });
  },

  onDateChange: function(e) {
    this.setData({
      selectedDate: e.detail.value
    });
  },

  onBooking: function() {
    if (!this.data.selectedDate) {
      wx.showToast({
        title: '请选择预定日期',
        icon: 'none'
      });
      return;
    }

    wx.showModal({
      title: '确认预定',
      content: `是否确认预定${this.data.product.name}？`,
      success: (res) => {
        if (res.confirm) {
          this.submitBooking();
        }
      }
    });
  },

  submitBooking: function() {
    // 这里实现预定提交逻辑
    wx.showLoading({
      title: '提交中...'
    });

    // 模拟API调用
    setTimeout(() => {
      wx.hideLoading();
      wx.showToast({
        title: '预定成功',
        icon: 'success'
      });
      
      setTimeout(() => {
        wx.switchTab({
          url: '/pages/my-orders/my-orders'
        });
      }, 1500);
    }, 1000);
  }
});
