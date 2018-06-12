
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
