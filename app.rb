require("bundler/setup")
Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }
also_reload('lib/**/*.rb')

#all recipes
get('/') do
  @recipes = Recipe.all
  erb(:index)
end
post('/') do
  @recipe = Recipe.find(params[:r_id].to_i)
  if params[:tag_ids]==nil
    @checked_tags = []
  else
    @checked_tags = params[:tag_ids]
  end
  @recipe.associate_tag(params[:tag_ids])

  @recipe.update({
    :name=>params[:r_name],
    :instructions=>params[:instructions],
    :rating=>params[:rating],
    })
  @recipes = Recipe.all
  erb(:index)
end

#add recipe
get('/recipes/new') do
  @recipe = Recipe.create(:name=>"", :instructions=> "", :rating=>0)
  @r_name = ""
  @instructions = ""
  @rating = 0
  @tags = Tag.all
  @checked_tags = []
  erb(:new_recipe)
end

post('/recipes/new') do
  @recipe = Recipe.find(params[:r_id].to_i)
  @tags = Tag.all

  if params[:tag_ids]==nil
    @checked_tags = []
  else
    @checked_tags = params[:tag_ids]
  end

  if params[:button]=='1'
    @r_name = params[:r_name]
    @instructions = params[:instructions]
    @rating = params[:rating]

    if Ingredient.dup_check(params[:i_name])!=0
      ingredient = Ingredient.find(Ingredient.dup_check(params[:i_name]).to_i)
      @recipe.ingredients.push(ingredient)
      @recipe.materials[-1].update({:amount => params[:amount]})
    else
      @recipe.ingredients.create({:name=>params[:i_name]})
      @recipe.materials[-1].update({:amount => params[:amount]})
    end
    erb(:new_recipe)
  else
    redirect '/', 307
  end
end

# one recipe
get('/recipes/:id') do
  @recipe = Recipe.find(params[:id].to_i)
  erb(:one_recipe)
end
post('/recipes/:id') do
  @recipe = Recipe.find(params[:id].to_i)
  @recipe.update({:name => params[:r_name], :instructions => params[:instructions], :rating => params[:rating]})
  @recipe.associate_tag(params[:tag_ids])
  erb(:one_recipe)
end

get('/recipes/:id/edit') do
  @recipe = Recipe.find(params[:id].to_i)
  @r_name = @recipe.name
  @instructions = @recipe.instructions
  @rating = @recipe.rating
  @tags = Tag.all
  @checked_tags = @recipe.tag_ids
  erb(:edit_recipe)
end

post('/recipes/:id/edit') do
  @recipe = Recipe.find(params[:id].to_i)
  @r_name = @recipe.name
  @instructions = @recipe.instructions
  @rating = @recipe.rating
  @tags = Tag.all
  @checked_tags = @recipe.tag_ids
  if params[:button]=='1'
    @r_name = params[:r_name]
    @instructions = params[:instructions]
    @rating = params[:rating]

    if Ingredient.dup_check(params[:i_name])!=0
      ingredient = Ingredient.find(Ingredient.dup_check(params[:i_name]).to_i)
      @recipe.ingredients.push(ingredient)
      @recipe.materials[-1].update({:amount => params[:amount]})
    else
      @recipe.ingredients.create({:name=>params[:i_name]})
      @recipe.materials[-1].update({:amount => params[:amount]})
    end
    erb(:new_recipe)
  elsif params[:button]=='2'
    redirect '/recipes/'.concat(@recipe.id.to_s), 307
  else
    redirect '/recipes/'.concat(@recipe.id.to_s).concat('/delete') #delete code
  end
  erb(:edit_recipe)
end
get('/recipes/:id/delete') do
  @recipe = Recipe.find(params[:id].to_i)
  @r_name = @recipe.name
  @instructions = @recipe.instructions
  @rating = @recipe.rating
  @tags = Tag.all
  @checked_tags = @recipe.tag_ids

  if params[:ingredient_ids]!=nil
    params[:ingredient_ids].each do |id|
      @recipe.materials.each do |join|
        if join.ingredient_id==id
          join.destroy
        end
      end
    end
  end
  erb(:edit_recipe)
end

#all tags
get('/tags') do
  @tags = Tag.all
  erb(:all_tags)
end
post('/tags') do
  Tag.create({:name=>params[:t_name]})
  @tags = Tag.all
  erb(:all_tags)
end

#one tag
get('/tags/:t_id') do
  @tag = Tag.find(params[:t_id].to_i)
  @t_recipes = @tag.recipes
  erb(:one_tag)
end




#clean database
get('/kill') do
  Recipe.all().each() do |recipe|
    recipe.destroy()
  end
  Tag.all().each() do |tag|
    tag.destroy()
  end
  Ingredient.all().each() do |ingredient|
    ingredient.destroy()
  end
  Material.all.each do |material|
    material.destroy()
  end
  Label.all.each do |label|
    label.destroy()
  end
  @recipes = Recipe.all
  @tags = Tag.all
  erb(:index)
end
