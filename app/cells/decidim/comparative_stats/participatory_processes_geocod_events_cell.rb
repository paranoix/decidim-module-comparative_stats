# frozen_string_literal: true

module Decidim
  module ComparativeStats
    # This cell renders a map with participatory processes
    # the `model` is spected to be a collection of API endpoints
    #
    class ParticipatoryProcessesGeocodEventsCell < Decidim::ViewModel
      include Decidim::MapHelper

      view_paths << "#{Decidim::ComparativeStats::Engine.root}/app/cells/decidim/comparative_stats/partipatory_processes_geocod_events"

      def show
        render :show
      end

      def endpoints
        Decidim::ComparativeStats::Endpoint.all
      end

      def upcoming_events
        @events = {
          meetings: {},
          proposals: {}
        }

        endpoints.each do |endpoint|
          results = endpoint.api.fetch_global_events
          results.data.assemblies.each do |assembly|
            assembly.components.each do |component|
              if component.respond_to? :meetings
                component.meetings.edges.each do |edge|
                  add_meeting(edge.node, endpoint.endpoint, assembly, component, :assemblies)
                end
              elsif componet.respond_to? :proposals
                component.proposals.edges.each do |edge|
                  add_proposal(edge.node, endpoint.endpoint, assembly, component, :assemblies)
                end
              end
            end
          end
          results.data.participatory_processes.each do |participatory_process|
            participatory_process.components.each do |component|
              if component.respond_to? :meetings
                component.meetings.edges.each do |edge|
                  add_meeting(edge.node, endpoint.endpoint, participatory_process, component, :processes)
                end
              elsif component.respond_to? :proposals
                component.proposals.edges.each do |edge|
                  add_proposal(edge.node, endpoint.endpoint, participatory_process, component, :processes)
                end
              end
            end
          end
        end
        @events.to_json
      end

      def first_text(translations)
        item = translations.find { |i| i.text.present? }
        item&.text || ""
      end

      def add_proposal(proposal, endpoint, participatory_space, component, type)
        @events[:proposals]["#{type}_proposal_#{proposal.id}"] = {
          latitude: proposal.coordinates.latitude,
          longitude: proposal.coordinates.longitude,
          address: proposal.address,
          title: proposal.title,
          body: truncate(proposal.body, length: 100),
          # icon: icon("proposals", width: 40, height: 70, remove_icon_class: true),
          link: endpoint.remove("api") << "#{type}/#{participatory_space.slug}/f/#{component.id}/proposals/#{proposal.id}"
        }
      end

      def add_meeting(meeting, endpoint, participatory_space, component, type)
        @events[:meetings]["#{type}_meeting_#{meeting.id}"] = {
          latitude: meeting.coordinates.latitude,
          longitude: meeting.coordinates.longitude,
          address: meeting.address,
          title: first_text(meeting.title.translations),
          # description: meeting.description,
          startTimeDay: l(meeting.start_time.to_date, format: "%d"),
          startTimeMonth: l(meeting.start_time.to_date, format: "%B"),
          startTimeYear: l(meeting.start_time.to_date, format: "%Y"),
          startTime: "#{meeting.start_time.to_date.strftime("%H:%M")} - #{meeting.end_time.to_date.strftime("%H:%M")}",
          # icon: icon("meetings", width: 40, height: 70, remove_icon_class: true),
          location: first_text(meeting.location.translations),
          locationHints: first_text(meeting.location_hints.translations),
          link: endpoint.remove("api") << "#{type}/#{participatory_space.slug}/f/#{component.id}/meetings/#{meeting.id}"
        }
      end
    end
  end
end