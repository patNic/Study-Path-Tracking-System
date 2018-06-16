var ctx = document.getElementById("line-chart");
var gwa = document.getElementById("gwa-variable").innerHTML;
var label = document.getElementById("label-variable").innerHTML;
var points = gwa.split(",  "); 
var labels1 = label.split("  ~  ");
var labels2 = [];
var i;
for(i = 0; i < labels1.length; i++) {
  labels2.push(labels1[i].split(" / "));
}

var lineChart = new Chart(ctx, {
  type: 'line',
  data: {
    labels: labels2,
    datasets: [
      {
        label: "GWA",
        data: points,
        backgroundColor: [
                'rgba(75, 192, 192, 0.2)'],
        fill: 'start',
        borderColor: [
                 'rgba(75, 192, 192, 1)']  
      }
    ]
  },
  options: {
    scales: {
      yAxes: [{
        ticks: {
          reverse: true,
          suggestedMin: 1,
          suggestedMax: 5,
        }
      }],
      xAxes: [{
        ticks: {
          autoSkip: false,
          minRotation: 0,
          maxRotation: 0
        }
      }]
    },
    legend: {
      display: false
    }
  }
}); 



var ctx = document.getElementById("myChart");
var points1 = document.getElementById("radar-values").innerHTML;
var points = points1.substr(1).slice(0, -1).split(",");
var points2 = [];
var i;
for(i = 0; i < points.length; i++) {
  points2.push(parseFloat(points[i]));
}

var myChart = new Chart(ctx, {
  type: 'radar',
  data: {
    labels: ["AH", "SSP", "Major", "Others", "Elective", "MST"],
    datasets: [{
      label: 'Progress',
      backgroundColor: "rgba(153,255,51,0.4)",
      borderColor: "rgba(153,255,51,1)",
      data: points2
    }]
  },
    options: {
    maintainAspectRatio: true,
    scale: {
        ticks: {
            beginAtZero: true,
            max: 100
        }
    }
  }
});
