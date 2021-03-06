class BabiesController < ApplicationController

  use Rack::Flash

  get '/babies/new' do
    redirect_if_not_logged_in
    erb :'babies/new'
  end

  post '/babies/new' do
    redirect_if_not_logged_in
    @baby = current_user.babies.create(params)
    if @baby.save
      flash[:message] = "You added #{@baby.name} to your account."
      redirect "/users/#{current_user.slug}"
    else
      erb :'babies/new'
    end
  end

  get '/babies/existing' do
    redirect_if_not_logged_in
    erb :'babies/existing'
  end

  post '/babies/existing' do
    redirect_if_not_logged_in
    if @baby = Baby.find_by(name: params[:name], birthdate: params[:birthdate]).try(:authenticate, params[:password])
      if current_user.babies.include?(@baby)
        redirect "/users/#{current_user.slug}?error=#{@baby.name} is already included in your account."
      else
        current_user.babies << @baby
        flash[:message] = "You added #{@baby.name} to your account."
        redirect "/users/#{current_user.slug}"
      end
    else
      @error_message = "The entered information is not valid for an existing baby. Please try again."
      # new instance created to allow form in view to include previously entered data on subsequent attempts to add an existing baby after validation error
      @baby = Baby.new(params)
      erb :'babies/existing'
    end
  end

  get '/babies/:id' do
    redirect_if_not_logged_in
    @baby = current_user.babies.find_by_id(params[:id])
    if @baby
      @last_meal = @baby.meals.sort_by{|meal| [meal.entry_date, meal.entry_time]}.last
      @last_size = @baby.sizes.sort_by{|size| size.entry_date}.last
      erb :'babies/show'
    else
      redirect "/users/#{current_user.slug}?error=You may only view your own babies."
    end
  end

  delete '/babies/:id/delete' do
    redirect_if_not_logged_in
    baby = current_user.babies.find_by_id(params[:id])
    if baby
      current_user.babies.delete(baby)
      flash[:message] = "You removed #{baby.name} from your account."
      redirect "/users/#{current_user.slug}"
    else
      redirect "/users/#{current_user.slug}?error=You may only remove your own babies from the list of babies under your care."
    end
  end

  get '/babies/:id/edit' do
    redirect_if_not_logged_in
    @baby = current_user.babies.find_by_id(params[:id])
    if @baby
      @last_meal = @baby.meals.sort_by{|meal| [meal.entry_date, meal.entry_time]}.last
      @last_size = @baby.sizes.sort_by{|size| size.entry_date}.last
      erb :'babies/edit'
    else
      redirect "/users/#{current_user.slug}?error=You may only edit information for your own babies."
    end
  end

  patch "/babies/:id" do
    redirect_if_not_logged_in
    baby = current_user.babies.find_by_id(params[:id])
    if baby
      baby.update(birthdate: params[:birthdate])
      redirect "/babies/#{baby.id}"
    else
      redirect "/users/#{current_user.slug}?error=You may only edit information for your own babies."
    end
  end

end
