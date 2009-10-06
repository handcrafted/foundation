class Admin::<%= class_name.pluralize %>Controller < AdminController
  before_filter :find_<%= singular_name %>, :except => [:index, :new, :create]

  def index
    @page = params[:page] || 1
    @<%= plural_name %> = <%= class_name %>.paginate(:all, :page => @page)
    
    respond_to do |format|
      format.html
    end    
  end

  def show
    redirect_to edit_<%= singular_name %>_url(@<%= singular_name %>)
  end

  def new
    @<%= singular_name %> = <%= class_name %>.new
  end

  def edit
    
  end

  def create
    @<%= singular_name %> = <%= class_name %>.new(params[:<%= singular_name %>])
    respond_to do |format|
      if @<%= singular_name %>.save
        format.html { redirect_to admin_<%= plural_name %>_url }
      else
        format.html { render :action => :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>]) 
        format.html { redirect_to admin_<%= plural_name %>_url }
      else
        format.html { render :action => :edit }
      end
    end
  end

  private
  
  def find_<%= singular_name %>
    @<%= singular_name %> = <%= class_name %>.find(params[:id])
  end

end