document.addEventListener("DOMContentLoaded", () => {

    // Fade-in animation
    const items = document.querySelectorAll(".card, .glass-card, .hero-content");

    const observer = new IntersectionObserver((entries) => {

        entries.forEach(entry => {

            if (entry.isIntersecting) {

                entry.target.style.opacity = "1";
                entry.target.style.transform = "translateY(0)";
                observer.unobserve(entry.target);

            }

        });

    }, {
        threshold: 0.15
    });

    items.forEach(item => {

        item.style.opacity = "0";
        item.style.transform = "translateY(40px)";
        item.style.transition = "all .7s ease";

        observer.observe(item);

    });

    // -----------------------------
    // Dark Mode
    // -----------------------------

    const darkBtn = document.createElement("button");

    darkBtn.innerHTML = "🌙";

    darkBtn.style.position = "fixed";
    darkBtn.style.right = "20px";
    darkBtn.style.bottom = "20px";
    darkBtn.style.width = "55px";
    darkBtn.style.height = "55px";
    darkBtn.style.borderRadius = "50%";
    darkBtn.style.border = "none";
    darkBtn.style.cursor = "pointer";
    darkBtn.style.fontSize = "22px";
    darkBtn.style.boxShadow = "0 10px 25px rgba(0,0,0,.2)";
    darkBtn.style.background = "#18b87b";
    darkBtn.style.color = "#fff";
    darkBtn.style.zIndex = "999";

    document.body.appendChild(darkBtn);

    function enableDark() {

        document.body.style.background = "#111827";
        document.body.style.color = "#ffffff";

        document.querySelectorAll(".glass-card,.card").forEach(e => {

            e.style.background = "rgba(30,41,59,.75)";
            e.style.color = "#fff";
            e.style.border = "1px solid rgba(255,255,255,.08)";

        });

        document.querySelectorAll("p").forEach(e => {

            e.style.color = "#d1d5db";

        });

        const footer = document.querySelector("footer");

        if (footer) {

            footer.style.background = "#020617";

        }

        localStorage.setItem("theme", "dark");

        darkBtn.innerHTML = "☀️";

    }

    function enableLight() {

        location.reload();

    }

    if (localStorage.getItem("theme") === "dark") {

        enableDark();

    }

    darkBtn.onclick = () => {

        if (localStorage.getItem("theme") === "dark") {

            localStorage.removeItem("theme");
            enableLight();

        } else {

            enableDark();

        }

    };

    // -----------------------------
    // Smooth Scroll
    // -----------------------------

    document.querySelectorAll("a[href^='#']").forEach(anchor => {

        anchor.addEventListener("click", function (e) {

            e.preventDefault();

            const target = document.querySelector(this.getAttribute("href"));

            if (target) {

                target.scrollIntoView({

                    behavior: "smooth"

                });

            }

        });

    });

});