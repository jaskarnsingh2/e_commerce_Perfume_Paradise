import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["subtotal", "pst", "gst", "hst", "total", "province"]

  connect() {
    console.log("Tax calculation controller connected")
  }

  updateTaxes() {
    console.log("Updating taxes")
    const provinceId = this.provinceTarget.value
    if (!provinceId) return
    
    console.log(`Fetching tax rates for province ID: ${provinceId}`)
    fetch(`/provinces/${provinceId}/tax_rates`)
      .then(response => response.json())
      .then(data => {
        console.log("Tax rates received:", data)
        const subtotal = parseFloat(this.subtotalTarget.dataset.value)
        
        const pstAmount = subtotal * (data.pst || 0) / 100
        const gstAmount = subtotal * (data.gst || 0) / 100
        const hstAmount = subtotal * (data.hst || 0) / 100
        const totalTax = pstAmount + gstAmount + hstAmount
        const total = subtotal + totalTax
        
        // Update the tax percentage display
        const pstLabel = this.pstTarget.previousElementSibling
        pstLabel.textContent = `PST (${data.pst || 0}%):`
        
        const gstLabel = this.gstTarget.previousElementSibling
        gstLabel.textContent = `GST (${data.gst || 0}%):`
        
        const hstLabel = this.hstTarget.previousElementSibling
        hstLabel.textContent = `HST (${data.hst || 0}%):`
        
        // Update the monetary values
        this.pstTarget.textContent = `$${pstAmount.toFixed(2)}`
        this.gstTarget.textContent = `$${gstAmount.toFixed(2)}`
        this.hstTarget.textContent = `$${hstAmount.toFixed(2)}`
        this.totalTarget.textContent = `$${total.toFixed(2)}`
      })
      .catch(error => {
        console.error("Error fetching tax rates:", error)
      })
  }
}