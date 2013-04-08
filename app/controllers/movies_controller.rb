class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    cnd = ""
    a,b = false,false
    if !params[:ratings].nil? and params[:ratings].length != 0 then
      @all_ratings = Movie.select("rating").map{ |e| e.rating }.uniq
      @ratings =  params[:ratings].map{ |k,v| k }
      session[:ratings] = @ratings
      
      empty = {} 
      @ratings.each { |x| empty[x] = 1 }
      @debug = params[:ratings]
    else
      a = true
      @all_ratings = Movie.select("rating").map{ |e| e.rating }.uniq
      @ratings = session[:ratings] ? session[:ratings] : @all_ratings
    end
   
    @ratings.each_with_index do |e, index| 
      if index != @ratings.size - 1
        cnd += "rating = '#{e}' OR "
      else
        cnd += "rating = '#{e}'"
      end
    end

    if !params[:sort].nil? then 
      @movies = Movie.where(cnd).order(params[:sort])
      instance_variable_set("@#{params[:sort]}", params[:sort])
      @sort = params[:sort]
      session[:sort] = params[:sort]
    else
      instance_variable_set("@#{session[:sort]}", session[:sort])
      @sort = session[:sort] if session[:sort] 
      b = true
      if session[:sort] then
        @movies = Movie.where(cnd).order(session[:sort])
      else
        @movies = Movie.where(cnd)
      end
    end    

    if a == true and b == true then
      
      redirect_to :action => "index", :ratings => @ratings, :sort => @sort and return
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
