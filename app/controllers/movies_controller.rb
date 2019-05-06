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
    @sort_method = params[:sort_by] || session[:sort_by]
    if params[:sort_by] == 'title'
        order_params, @title_header={:title => :asc}, 'hilite'
    elsif params[:sort_by] == 'release_date'
        order_params, @date_header={:release_date => :asc}, 'hilite'
    end
    
    @ratings = Movie.all_ratings
    @ratings_selected = params[:ratings] || session[:ratings] || {}
    
    if @ratings_selected == {}
      @ratings_selected = Hash[@ratings.map {|rating| [rating, rating]}]
    end
    
    if (params[:sort_by] != session[:sort_by]) || (params[:ratings] != session[:ratings])
      session[:sort_by] = @sort_method
      session[:ratings] = @ratings_selected
      redirect_to :sort_by => @sort_method, :ratings => @ratings_selected and return
    end
    
    @movies = Movie.where(:rating => @ratings_selected.keys).order(order_params)
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
