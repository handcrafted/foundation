module SortableTableHelper
  
  def sortable_table(objects, model = nil, options = {})
    options.reverse_merge!(fetch_headers(options, model)) unless model.nil?
    render :partial => "shared/sortable_table/table", :locals => {:objects => objects, :options => options}
  end
  
  def fetch_headers(options, model)
    columns = model.column_names.collect {|column| column.to_sym}
    {:headers => columns, :data => columns}
  end
  
end