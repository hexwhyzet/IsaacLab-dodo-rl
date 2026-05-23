# Copyright (c) 2022-2026, The Isaac Lab Project Developers (https://github.com/isaac-sim/IsaacLab/blob/main/CONTRIBUTORS.md).
# All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

"""Configuration for the Dodo (dodo_daimao) bipedal robot.

The following configurations are available:

* :obj:`DODO_CFG`: Dodo biped with implicit PD actuators (full mesh).
* :obj:`DODO_SIMPLE_CFG`: Dodo biped using the simplified mesh variant.

URDF source: https://huggingface.co/ultravanish/dodo-rl-checkpoints
USD assets:  ``source/isaaclab_assets/data/Robots/Dodo/``

Robot specs (from dodo_daimao.urdf):
  - Body mass: 3.31 kg
  - 8 actuated revolute joints (4 per leg: hip / upper_leg / lower_leg / foot)
  - 2 fixed joints (foot_sole_left/right — contact pads)
  - Hip joints rotate about X-axis (±0.35 rad, 27 Nm, 6 rad/s)
  - Upper-leg / lower-leg / foot joints rotate about Y-axis
  - Controller joint order (index 0 is empty placeholder):
    ['', 'hip_right', 'upper_leg_right', 'lower_leg_right', 'foot_right',
          'hip_left',  'upper_leg_left',  'lower_leg_left',  'foot_left']

.. note::
    Stiffness and damping values are initial estimates scaled from robot effort
    limits. Tune them before sim-to-real transfer.
"""

import isaaclab.sim as sim_utils
from isaaclab.actuators import ImplicitActuatorCfg
from isaaclab.assets.articulation import ArticulationCfg

from isaaclab_assets import ISAACLAB_ASSETS_DATA_DIR

##
# Configuration
##

DODO_CFG = ArticulationCfg(
    spawn=sim_utils.UsdFileCfg(
        usd_path=f"{ISAACLAB_ASSETS_DATA_DIR}/Robots/Dodo/dodo_ROS.usd",
        activate_contact_sensors=True,
        rigid_props=sim_utils.RigidBodyPropertiesCfg(
            disable_gravity=False,
            retain_accelerations=False,
            linear_damping=0.0,
            angular_damping=0.0,
            max_linear_velocity=1000.0,
            max_angular_velocity=1000.0,
            max_depenetration_velocity=1.0,
        ),
        articulation_props=sim_utils.ArticulationRootPropertiesCfg(
            enabled_self_collisions=True,
            solver_position_iteration_count=4,
            solver_velocity_iteration_count=0,
        ),
    ),
    init_state=ArticulationCfg.InitialStateCfg(
        pos=(0.0, 0.0, 0.5),
        joint_pos={
            # Hip joints (X-axis, ±0.35 rad)
            "hip_right": 0.0,
            "hip_left": 0.0,
            # Upper-leg joints (Y-axis, ±1.57 rad)
            "upper_leg_right": 0.3,
            "upper_leg_left": 0.3,
            # Lower-leg joints (Y-axis, -3.14..1.40 rad)
            "lower_leg_right": -0.6,
            "lower_leg_left": -0.6,
            # Foot/ankle joints (Y-axis, -1.05..1.57 rad)
            "foot_right": 0.3,
            "foot_left": 0.3,
        },
        joint_vel={".*": 0.0},
    ),
    soft_joint_pos_limit_factor=0.9,
    actuators={
        # Hip abduction/adduction — 27 Nm effort, ±0.35 rad range
        "hips": ImplicitActuatorCfg(
            joint_names_expr=["hip_.*"],
            effort_limit_sim=27.0,
            velocity_limit_sim=6.0,
            stiffness={"hip_.*": 30.0},
            damping={"hip_.*": 1.5},
        ),
        # Thigh flexion/extension — 27 Nm effort, ±1.57 rad range
        "upper_legs": ImplicitActuatorCfg(
            joint_names_expr=["upper_leg_.*"],
            effort_limit_sim=27.0,
            velocity_limit_sim=6.0,
            stiffness={"upper_leg_.*": 40.0},
            damping={"upper_leg_.*": 2.0},
        ),
        # Knee flexion/extension — 9 Nm effort
        "lower_legs": ImplicitActuatorCfg(
            joint_names_expr=["lower_leg_.*"],
            effort_limit_sim=9.0,
            velocity_limit_sim=6.0,
            stiffness={"lower_leg_.*": 15.0},
            damping={"lower_leg_.*": 0.8},
        ),
        # Ankle flexion/extension — 9 Nm effort
        "feet": ImplicitActuatorCfg(
            joint_names_expr=["foot_right", "foot_left"],
            effort_limit_sim=9.0,
            velocity_limit_sim=6.0,
            stiffness={"foot_.*": 10.0},
            damping={"foot_.*": 0.5},
        ),
        # foot_sole_left / foot_sole_right are fixed joints — excluded automatically
    },
)
"""Configuration for the Dodo bipedal robot (full mesh, ROS USD)."""


DODO_SIMPLE_CFG = DODO_CFG.replace(
    spawn=DODO_CFG.spawn.replace(
        # TODO: a standalone top-level simple USD does not exist in the repo.
        # dodo_simple_ROS_robot.usd is a sublayer assembly file (1.8 kB), not a
        # fully composed USD. Either compose a dodo_simple_ROS.usd manually in
        # Isaac Sim, or use DODO_CFG until a proper simple entry-point is available.
        usd_path=f"{ISAACLAB_ASSETS_DATA_DIR}/Robots/Dodo/configuration/dodo_simple_ROS_robot.usd",
    )
)
"""Configuration for the Dodo robot using the simplified mesh (faster simulation).

.. warning::
    ``dodo_simple_ROS_robot.usd`` is a sublayer assembly file, not a standalone
    composed USD. Use :obj:`DODO_CFG` until a proper top-level simple USD is created.
"""
