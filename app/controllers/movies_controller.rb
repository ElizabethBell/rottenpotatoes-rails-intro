class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @sort = nil
    @ratings = @all_ratings
    
    if params.fetch("ratings", false)
      @ratings = params[:ratings].keys
    end
    
    if ["title", "release_date"].member?(params.fetch("sort", nil))
      @sort = params[:sort]
    end
    
    sess_sort = session.fetch("movies_sort", nil)
    sess_ratings = session.fetch("movies_ratings", @all_ratings)
    
    if (@ratings == @all_ratings and @sort == nil and (sess_ratings != @all_ratings or sess_sort != nil))
      flash.keep
      ratings_params = Hash[*sess_ratings.collect{|k| [k, "1"]}.flatten]
      return redirect_to movies_path(nil, {:sort => sess_sort, :ratings => ratings_params})
    end
    
    @movies = Movie.where(:rating => @ratings)
    if @sort != nil
      @movies = @movies.order(@sort)
    end
    
    session[:movies_sort] = @sort
    session[:movies_ratings] = @ratings
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
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
