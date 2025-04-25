class ProvincesController < ApplicationController
    # Add your existing controller methods...
  
    def tax_rates
      province = Province.find(params[:id])
      render json: {
        pst: province.pst,
        gst: province.gst,
        hst: province.hst
      }
    end
  end