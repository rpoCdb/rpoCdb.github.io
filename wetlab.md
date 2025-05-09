---
title: Primers & PCR Protocol
layout: home
nav_order: 5
---

## Primer sequences:

<div style="font-size: 1em; margin: 15px 0;">
  <strong>Forward Primer (rpoCF):</strong><br>
  <code style="font-size: 1em;">5' - MAYGARAARMGNATGYTNCARGA - 3'</code>
</div>

<div style="font-size: 1em; margin: 15px 0;">
  <strong>Reverse Primer (rpoCR):</strong><br>
  <code style="font-size: 1em;">5' - GMCATYTGRTCNCCRTCRAA - 3'</code>
</div>

## Illumina Sequencing Library Prep Protocol

### PCR Master Mix

| **Reagent**           |**Per reaction**|
|-----------------------|----------------|
| Platinum Hot Start MM | 10 µL          |
| rpoCF (10 µM)         | 0.5 µL         |
| rpoCR (10 µM)         | 0.5 µL         |
| Molecular-grade H₂O   | 10 µL          |
| Template DNA          | 4.0 µL         |
| Total reaction volume | 25 µL          |


### Thermocycler Conditions
**Lid Temperature:** 105°C  
**Total Volume:** 25 µL  

<table style="border-collapse: collapse; width: 100%; margin-top: 15px;">
  <thead>
    <tr style="background-color: #f8f9fa;">
      <th style="padding: 10px; border-bottom: 2px solid #ddd;">Temperature</th>
      <th style="padding: 10px; border-bottom: 2px solid #ddd;">Time</th>
      <th style="padding: 10px; border-bottom: 2px solid #ddd;">Cycles</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="padding: 8px; border-bottom: 1px solid #eee;">94°C</td>
      <td style="padding: 8px; border-bottom: 1px solid #eee;">3 min</td>
      <td style="padding: 8px; border-bottom: 1px solid #eee;"></td>
    </tr>
    <tr>
      <td style="padding: 8px; border-bottom: 1px solid #eee;">94°C</td>
      <td style="padding: 8px; border-bottom: 1px solid #eee;">45 sec</td>
      <td style="padding: 8px; border: 2px solid #000; border-bottom: none;"></td>
    </tr>
    <tr>
      <td style="padding: 8px; border-bottom: 1px solid #eee;">39.5°C</td>
      <td style="padding: 8px; border-bottom: 1px solid #eee;">1 min</td>
      <td style="padding: 8px; border-left: 2px solid #000; border-right: 2px solid #000; background-color: #f8f9fa; text-align: center; vertical-align: middle;">
        <strong>40x</strong>
      </td>
    </tr>
    <tr>
      <td style="padding: 8px; border-bottom: 1px solid #eee;">72°C</td>
      <td style="padding: 8px; border-bottom: 1px solid #eee;">1:30 min</td>
      <td style="padding: 8px; border: 2px solid #000; border-top: none;"></td>
    </tr>
    <tr>
      <td style="padding: 8px;">72°C</td>
      <td style="padding: 8px;">10 min</td>
      <td style="padding: 8px;"></td>
    </tr>
  </tbody>
</table>