# -*- encoding : utf-8 -*-

class Card < ActiveRecord::Base
  class Reference < ActiveRecord::Base
    def referencer
      Card[referer_id]
    end

    def referencee
      Card[referee_id]
    end

    class << self
      def delete_all_from card
        delete_all :referer_id => card.id
      end
      
      def delete_all_to card
        where( :referee_id => card.id ).update_all :present=>0, :referee_id => nil
      end
      
      def update_on_create card
        where( :referee_key => card.key ).update_all :present => 1, :referee_id => card.id
      end

      def update_on_rename card, newname, update_referers=false
        if update_referers
          # not currentlt needed because references are deleted and re-created in the process of adding new revision
          #where( :referee_id=>card.id ).update_all :referee_key => newname.to_name.key
        else
          delete_all_to card
        end
        where( :referee_key => newname.to_name.key ).update_all :present => 1, :referee_id => card.id
      end

      def update_on_destroy card
        delete_all_from card
        delete_all_to card
      end
    end
  end
end
