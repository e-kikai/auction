class System::AbtestsController < System::ApplicationController
  include Exports

  def index
    @labels   = Abtest.group(:label).order("minimum_created_at DESC").minimum(:created_at)

    @start    = Abtest.group(:label, :segment).count(:id)
    @finished = Abtest.group(:label, :segment).where.not(finished_at: nil).count(:id)

    @checkpoints = Abtest.joins(:ab_checkpoints)
      .group(:label, :segment, "ab_checkpoints.key").count("ab_checkpoints.id")

    @test = AbCheckpoint.all
    respond_to do |format|
      format.html
      format.csv { export_csv "abtests_#{@date.strftime('%Y_%m')}.csv" }
    end
  end
end
