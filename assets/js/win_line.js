function draw_line(first_id, second_id) {
  remove_line();

  const first_box = document
    .getElementById(`square-${first_id}`)
    ?.getBoundingClientRect();
  const second_box = document
    .getElementById(`square-${second_id}`)
    ?.getBoundingClientRect();

  const board_box = document.getElementById("board")?.getBoundingClientRect();

  if (!first_box || !second_box) {
    console.error("box does not exist");
    return;
  }

  const first_column = first_id % 3;
  const second_column = second_id % 3;

  const diff = first_column - second_column;

  const first_row = Math.ceil(first_id / 3);
  const second_row = Math.ceil(second_id / 3);

  const verticalLine = first_column === second_column;
  const horizontalLine = first_row === second_row;
  const leftToRight = diff > 0;

  let startPoint, endPoint;

  if (verticalLine) {
    let x = first_box.left + first_box.width / 2;

    startPoint = {
      x,
      y: first_box.top
    };
    endPoint = {
      x,
      y: second_box.bottom
    };
  } else if (horizontalLine) {
    let y = first_box.top + first_box.height / 2;

    startPoint = {
      x: first_box.left,
      y
    };
    endPoint = {
      x: second_box.right,
      y
    };
  } else if (leftToRight) {
    // left to right
    startPoint = {
      x: first_box.left,
      y: first_box.top
    };
    endPoint = {
      x: second_box.right,
      y: second_box.bottom
    };
  } else {
    // right to left
    startPoint = {
      x: first_box.right,
      y: first_box.top
    };
    endPoint = {
      x: second_box.left,
      y: second_box.bottom
    };
  }

  let width;

  if (verticalLine) {
    width = endPoint.y - startPoint.y;
  } else if (horizontalLine) {
    width = endPoint.x - startPoint.x;
  } else {
    // use pythagorean theorem
    const a = Math.pow(endPoint.x - startPoint.x, 2);
    const b = Math.pow(endPoint.y - startPoint.y, 2);
    width = Math.sqrt(a + b);
  }

  const line = document.createElement("div");

  let classes = ["h-1", "transform", "border-2", "border-red-400", "absolute"];

  if (verticalLine) {
    classes.push("rotate-90");
  } else if (!horizontalLine) {
    classes.push(leftToRight ? "rotate-45" : "-rotate-45");
  }

  line.classList.add(...classes);

  line.style.width = `${width}px`;
  if (horizontalLine) {
    line.style.top = `${startPoint.y}px`;
    line.style.left = `${startPoint.x}px`;
  } else if (verticalLine) {
    // subtract 2 to account for border (I think?)
    line.style.top = `${(startPoint.y + endPoint.y) / 2 - 2}px`;
    line.style.left = `${first_box.left - first_box.width}px`;
  } else {
    const additionalX = (width - board_box.width) / 2;
    line.style.top = `${(startPoint.y + endPoint.y) / 2 - 2}px`;
    line.style.left = `${board_box.left - additionalX}px`;
  }
  line.id = "win_line";

  document.getElementById("container").appendChild(line);
}

function remove_line() {
  const line = document.getElementById("win_line");

  if (line) {
    document.getElementById("container").removeChild(line);
  }
}

window.draw_line = draw_line;
window.remove_line = remove_line;
