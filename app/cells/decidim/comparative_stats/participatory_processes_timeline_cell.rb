# frozen_string_literal: true

require "chartkick"
require "chartkick/helper"

module Decidim
  module ComparativeStats
    # This cell renders an graph with participatory processes
    # the `model` is spected to be a collection of API endpoints
    #
    class ParticipatoryProcessesTimelineCell < Decidim::ViewModel
      include Chartkick::Helper

      def show
        return unless model

        render :show
      end

      def endpoints
        model
      end

      def timeline_graph
        rows = []
        endpoints.each do |endpoint|
          endpoint.api.fetch_participatory_processes.data.participatory_processes.each do |item|
            rows << {
              name: endpoint.name,
              title: item.title.translations.first.text,
              start_date: item.start_date,
              end_date: item.end_date
            }
          end
        end
        rows
      end
    end
  end
end
