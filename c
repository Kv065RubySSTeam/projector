
[1mFrom:[0m /home/et/rails/soft/projector/app/controllers/cards_controller.rb:45 CardsController#update:

    [1;34m23[0m: [32mdef[0m [1;34mupdate[0m
    [1;34m24[0m:   [1;34m# unless card_params.empty?[0m
    [1;34m25[0m:   [1;34m#   @card = @column.cards.find(params[:id])[0m
    [1;34m26[0m:   [1;34m#   @card.update(card_params)[0m
    [1;34m27[0m:   [1;34m#   respond_to do |f|[0m
    [1;34m28[0m:   [1;34m#     if @card.valid?[0m
    [1;34m29[0m:   [1;34m#       f.js { flash[:success] = "Card was successfully updated." }[0m
    [1;34m30[0m:   [1;34m#     else[0m
    [1;34m31[0m:   [1;34m#       f.js { flash[:error] = @card.errors.full_messages.join("\n") }[0m
    [1;34m32[0m:   [1;34m#     end[0m
    [1;34m33[0m:   [1;34m#   end[0m
    [1;34m34[0m:   [1;34m# else[0m
    [1;34m35[0m:     cards_id = eval(params[[33m:cards_id[0m])
    [1;34m36[0m:     @card = [1;34;4mCard[0m.find(params[[33m:id[0m])
    [1;34m37[0m:     @card.update([35mcolumn_id[0m: params[[33m:column_id[0m], [35mposition[0m: rand([1;34m100[0m..[1;34m200[0m))
    [1;34m38[0m:     cards = @column.cards
    [1;34m39[0m:     ([1;34m0[0m...cards.length).each [32mdo[0m |index|
    [1;34m40[0m:       card = cards.find(cards_id[index])
    [1;34m41[0m:       card.position = index + [1;34m1[0m
    [1;34m42[0m:       card.save
    [1;34m43[0m:     [32mend[0m
    [1;34m44[0m:     
 => [1;34m45[0m:     binding.pry
    [1;34m46[0m:     
    [1;34m47[0m:   [1;34m# end[0m
    [1;34m48[0m: [32mend[0m

