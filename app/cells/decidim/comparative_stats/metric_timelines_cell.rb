# frozen_string_literal: true

require "chartkick"
require "chartkick/helper"

module Decidim
  module ComparativeStats
    class MetricTimelinesCell < Decidim::ViewModel
      include Chartkick::Helper

      def show
        return unless model

        render :show
      end

      def endpoints
        model
      end

      def metrics
        history = {}
        endpoints.each do |endpoint|
          endpoint.api.fetch_global_history_metrics.data.metrics.each do |item|
            history[item.name] ||= []
            history[item.name] << {
              name: endpoint.name,
              data: item.history.map do |i|
                [i.key, i.value]
              end.to_h
            }
          end
        end
        history
      end
    end
  end
end
