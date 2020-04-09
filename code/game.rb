require './player.rb'

class Game

    def initialize(*player_names)
        @players = player_names.map { |player_name| Player.new(player_name) }
        self.player_scores

        @fragment = []
        @current_player = @players.sample

        self.create_dictionary
    end

    def create_dictionary
        dictionary_arr = File.open('dictionary.txt').readlines.map(&:chomp)
        @dictionary = Hash.new
        dictionary_arr.each do |word|
            @dictionary[word] = true
        end
    end

    def player_scores
        @player_scores = Hash.new

        @players.each do |player|
            @player_scores[player.player_name] = 0
        end
    end

    def ghost_score(player)
        word = 'GHOST'
        
        if @player_scores[player.player_name] > 0
            num_score = @player_scores[player.player_name]-1
        else
            num_score = 0
        end

        @word_score = word[0..num_score]
        @word_score
    end

    def player_turn
        puts "#{@current_player.player_name}, enter a letter"
        letter = gets.chomp
        
        if valid_play?(letter)
            @fragment << letter
        else
            puts
            puts 'invalid entry, try again'
            puts
            puts "Current word: #{@fragment.join('')}"
            puts
            self.player_turn
        end
    end

    def switch_player
        @previous_player = @current_player      
        next_player = @players[ (@players.index(@current_player) + 1) % @players.length ]
        
        @current_player = next_player
    end

    def valid_play?(letter)
        alpha = [*'a'..'z']
        possible_word = @fragment.join('') + letter

        if alpha.include?(letter.downcase) && @dictionary.keys.any? { |word| word[0...possible_word.length] == possible_word }
            return true
        end
        false
    end

    def valid_word?(word)
        @dictionary.has_key?(word)
    end

    def round_over?
        if valid_word?(@fragment.join(''))
            @player_scores[@previous_player.player_name] += 1
            if @player_scores[@previous_player.player_name] < 5
                puts
                puts "#{@previous_player.player_name}, you lose this round. You're at #{self.ghost_score(@previous_player)}!"
                puts
            else
                puts
                puts "#{@previous_player.player_name}, you lose this round. You're at #{self.ghost_score(@previous_player)}. You're out of the game!"
                puts                
                @players.delete_at(@players.index(@previous_player))
            end
            @fragment = []
            return true
        end
        false
    end

    def play_round
        while !self.round_over?
            puts
            puts "Current word: #{@fragment.join('')}"
            puts
            self.player_turn
            self.switch_player 
        end      
    end

    def game_over?
        if @players.length == 1
            puts
            puts "#{@players[0].player_name}, you are the champion!!!"
            puts
            return true 
        end
        false
    end

    def run
        while !self.game_over?
            self.play_round
        end
    end

end


game = Game.new('nico', 'anushka', 'laura')
game.run