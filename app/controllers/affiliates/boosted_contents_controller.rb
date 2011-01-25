class Affiliates::BoostedContentsController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate
  before_filter :find_boosted_content, :only => [:edit, :update, :destroy]

  def new
    @title = "Boosted Content - "
    @boosted_content = @affiliate.boosted_contents.new
  end

  def edit
    @title = "#{@boosted_content.title} - Edit Boosted Content Entry"
  end

  def update
    if @boosted_content.update_attributes(params[:boosted_content])
      flash[:success] = "Boosted Content entry successfully updated"
      redirect_to new_affiliate_boosted_content_path
    else
      flash[:error] = "There was a problem saving your Boosted Content entry"
      render :action => :edit
    end
  end

  def create
    @boosted_content = BoostedContent.create(params[:boosted_content].merge(:affiliate => @affiliate))
    if @boosted_content.errors.empty?
      flash[:success] = "Boosted Content entry successfully added for affiliate '#{@affiliate.name}'"
      redirect_to new_affiliate_boosted_content_path
    else
      flash[:error] = "There was a problem saving your Boosted Content entry"
      render :action => :new
    end
  end

  def destroy
    @boosted_content.destroy
    flash[:success] = "Boosted Content entry successfully deleted"
    redirect_to new_affiliate_boosted_content_path
  end

  def bulk
    if BoostedContent.process_boosted_content_xml_upload_for(@affiliate, params[:xml_file])
      flash[:success] = "Boosted Content entries uploaded successfully for affiliate '#{@affiliate.name}'"
      redirect_to new_affiliate_boosted_content_path
    else
      flash[:error] = "Your XML document could not be processed. Please check the format and try again."
      @boosted_content = @affiliate.boosted_contents.new
      render :action => 'new'
    end
  end

  private
  def find_boosted_content
    @boosted_content = BoostedContent.find(params[:id])
  end

end
