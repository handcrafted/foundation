(function($) {
  $.fn.equalizeCols = function(children){
    var child = Array(0);
    if (children) child = children.split(",");
    var maxH = 0;
    this.each(
      function(i) 
      {
        if (this.offsetHeight>maxH) maxH = this.offsetHeight;
      }
    ).css("height", "auto").each(
      function(i)
      {
        var gap = maxH-this.offsetHeight;
        if (gap > 0)
        {
          t = document.createElement('div');
          $(t).attr("class","fill").css("height",gap+"px");
          if (child.length > i)
          {
            $(this).find(child[i]).children(':last-child').after(t);
          } 
          else 
          {
            $(this).children(':last-child').after(t);
          }
        }
      }  
    );
    
  }
})(jQuery);